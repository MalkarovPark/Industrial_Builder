//
//  ListingListView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI
import IndustrialKit

struct ListingListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    
    @State private var new_code_view_presented = false
    @State private var new_listing_name = ""
    
    @State private var load_panel_presented = false
    @State private var clear_message_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.listing_items.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.listing_items)
                        { item in
                            ListingCard(listing_item: item)
                            { is_presented in
                                ListingView(is_presented: is_presented, listing_item: item)
                            }
                        }
                    }
                    .padding(20)
                }
                .animation(.spring(), value: base_stc.listing_items)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Listings", systemImage: "scroll")
                }
            }
        }
        .overlay
        {
            if is_targeted
            {
                VStack
                {
                    Text("Drop listings here")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .onDrop(of: [.swiftSource], isTargeted: $is_targeted)
        { providers in
            perform_drop(providers: providers)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar
        {
            Button(action: { new_code_view_presented.toggle() })
            {
                Image(systemName: "plus")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
            .sheet(isPresented: $new_code_view_presented)
            {
                CodeSelectorView(is_presented: $new_code_view_presented, avaliable_template_names: all_code_templates)
                { output in
                    if new_listing_name.isEmpty
                    {
                        new_listing_name = "Name"
                    }
                    
                    new_listing_name = unique_name(for: new_listing_name, in: base_stc.listing_items.map(\.name))
                    
                    base_stc.listing_items.append(ListingItem(name: new_listing_name, text: output))
                    new_listing_name = ""
                    
                    document_handler.document_update_listings()
                }
                .toolbar
                {
                    ToolbarItem(placement: .automatic)
                    {
                        TextField("Name", text: $new_listing_name)
                            .padding(.trailing)
                            .frame(minWidth: 128, maxWidth: 256)
                        #if os(iOS) || os(visionOS)
                            .frame(idealWidth: 256)
                            .textFieldStyle(.roundedBorder)
                        #endif
                    }
                }
            }
            
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
            .fileImporter(isPresented: $load_panel_presented,
                                  allowedContentTypes: [.swiftSource], allowsMultipleSelection: true, onCompletion: import_listings)
        }
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            DispatchQueue.main.async
            {
                provider.loadItem(forTypeIdentifier: "public.swift-source", options: nil)
                { (item, error) in
                    if let url = item as? URL
                    {
                        let file_name = url.lastPathComponent
                        
                        if let listing_data = try? Data(contentsOf: url)
                        {
                            guard let text = String(data: listing_data, encoding: .utf8)
                            else
                            {
                                return
                            }
                            base_stc.listing_items.append(ListingItem(name: String(file_name.split(separator: ".").first!), text: text))
                            
                            document_handler.drop_document_update_listings()
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func import_listings(_ res: Result<[URL], Error>)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            do
            {
                let urls = try res.get()
                
                for url in urls
                {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    if let listing_data = try? Data(contentsOf: url),
                       let text = String(data: listing_data, encoding: .utf8)
                    {
                        base_stc.listing_items.append(ListingItem(name: String(url.lastPathComponent.split(separator: ".").first!), text: text))
                    }
                    url.stopAccessingSecurityScopedResource()
                }
                document_handler.document_update_listings()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview
{
    ListingListView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
