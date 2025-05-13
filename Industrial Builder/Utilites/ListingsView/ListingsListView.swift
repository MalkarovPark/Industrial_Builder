//
//  ListingsListView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI
import IndustrialKit

struct ListingsListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    
    @State private var new_panel_presented = false
    @State private var new_listing_name = ""
    
    @State private var load_panel_presented = false
    @State private var clear_message_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.listings.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.listings.indices, id: \.self)
                        { index in
                            ListingCard(code: $base_stc.listings[index], name: base_stc.listings_files_names[index])
                            { is_presented in
                                ListingView(code: $base_stc.listings[index], is_presented: is_presented, label: base_stc.listings_files_names[index])
                            }
                        }
                    }
                    .padding(20)
                }
                // .modifier(DoubleModifier(update_toggle: $document_handler.update_listings_document_notify))
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
            Button(action: { new_panel_presented.toggle() })
            {
                Image(systemName: "plus")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
            .sheet(isPresented: $new_panel_presented)
            {
                #if os(macOS)
                CodeBuilderView(is_presented: $new_panel_presented, avaliable_templates_names: all_code_templates)
                { output in
                    if new_listing_name.isEmpty
                    {
                        new_listing_name = "Name"
                    }
                    
                    new_listing_name = mismatched_name(name: new_listing_name, names: base_stc.listings_files_names)
                    
                    base_stc.listings.append(output)
                    base_stc.listings_files_names.append(new_listing_name)
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
                #else
                CodeBuilderView(is_presented: $new_panel_presented,
                                avaliable_templates_names: all_code_templates,
                                bottom_view:
                                    TextField("Name", text: $new_listing_name)
                                        .padding(.trailing)
                                        .frame(minWidth: 128, maxWidth: 256)
                                        .frame(idealWidth: 256)
                                        .textFieldStyle(.roundedBorder)
                )
                { output in
                    if new_listing_name.isEmpty
                    {
                        new_listing_name = "Name"
                    }
                    
                    new_listing_name = mismatched_name(name: new_listing_name, names: base_stc.listings_files_names)
                    
                    base_stc.listings.append(output)
                    base_stc.listings_files_names.append(new_listing_name)
                    new_listing_name = ""
                    
                    document_handler.document_update_listings()
                }
                #endif
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
                            guard let listing = String(data: listing_data, encoding: .utf8)
                            else
                            {
                                return
                            }
                            base_stc.listings.append(listing)
                            base_stc.listings_files_names.append(String(file_name.split(separator: ".").first!))
                            
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
                    if let listing_data = try? Data(contentsOf: url), let listing = String(data: listing_data, encoding: .utf8)
                    {
                        base_stc.listings.append(listing)
                        base_stc.listings_files_names.append(String(url.lastPathComponent.split(separator: ".").first!))
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
    ListingsListView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
