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
                                ListingView(code: $base_stc.listings[index], is_presented: is_presented)
                            }
                        }
                    }
                    .padding(20)
                }
                .modifier(DoubleModifier(update_toggle: $document_handler.update_images_document_notify))
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
        .modifier(WindowFramer())
        .toolbar
        {
            Button(action: { new_panel_presented.toggle() })
            {
                Image(systemName: "plus")
            }
            .popover(isPresented: $new_panel_presented, arrowEdge: .bottom)
            {
                AddNewView(is_presented: $new_panel_presented, names: base_stc.listings_files_names)
                { new_name in
                    base_stc.listings.append("")
                    base_stc.listings_files_names.append(new_name)
                    
                    document_handler.document_update_listings()
                }
            }
            
            Button(action: { clear_message_presented.toggle() })
            {
                Image(systemName: "eraser")
            }
            .confirmationDialog(Text("Remove all listings?"), isPresented: $clear_message_presented)
            {
                Button("Remove", role: .destructive)
                {
                    base_stc.listings.removeAll()
                    base_stc.listings_files_names.removeAll()
                    document_handler.document_update_listings()
                }
            }
            
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            .fileImporter(isPresented: $load_panel_presented,
                                  allowedContentTypes: [.swiftSource], allowsMultipleSelection: true, onCompletion: import_listings)
        }
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        var even = false
        
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
                            
                            document_handler.document_update_listings()
                            if even
                            {
                                document_handler.document_update_listings()
                            }
                            even.toggle()
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
