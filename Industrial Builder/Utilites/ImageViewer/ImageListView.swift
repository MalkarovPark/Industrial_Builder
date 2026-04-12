//
//  ImageListView.swift
//  Industrial Builder
//
//  Created by Artem on 29.03.2024.
//

import SwiftUI
import IndustrialKit

struct ImageListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    @State private var clear_message_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    @State private var search_text: String = String()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.image_items.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(filtered_items)
                        { item in
                            ImageCard(image_item: item)
                            { is_presented in
                                ImageView(is_presented: is_presented, image: item.image, label: item.name)
                                    .frame(maxWidth: 800)
                            }
                        }
                    }
                    .padding(20)
                }
                .animation(.spring(), value: filtered_items)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Images", systemImage: "photo")
                }
            }
        }
        .overlay
        {
            if is_targeted
            {
                VStack
                {
                    Text("Drop images here")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .onDrop(of: [.image], isTargeted: $is_targeted)
        { providers in
            perform_drop(providers: providers)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar
        {
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
            .fileImporter(
                isPresented: $load_panel_presented,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true,
                onCompletion: import_images
            )
        }
        .searchable(text: $search_text)
    }
    
    private func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            DispatchQueue.main.async
            {
                provider.loadItem(forTypeIdentifier: "public.image", options: nil)
                { (item, error) in
                    if let url = item as? URL
                    {
                        let file_name = url.lastPathComponent
                        
                        if let image_data = try? Data(contentsOf: url)
                        {
                            guard let image = UIImage(data: image_data)
                            else
                            {
                                return
                            }
                            
                            base_stc.image_items.append(ImageItem(name: file_name, image: image))
                            
                            document_handler.drop_update_images()
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    private func import_images(_ res: Result<[URL], Error>)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            do
            {
                let urls = try res.get()
                
                for url in urls
                {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    if let image_data = try? Data(contentsOf: url), let image = UIImage(data: image_data)
                    {
                        base_stc.image_items.append(ImageItem(name: url.lastPathComponent, image: image))
                    }
                    url.stopAccessingSecurityScopedResource()
                }
                document_handler.update_images()
            }
            catch
            {
                //print(error.localizedDescription)
            }
        }
    }
    
    private var filtered_items: [ImageItem]
    {
        if search_text.isEmpty
        {
            return base_stc.image_items
        }
        
        return base_stc.image_items.filter
        {
            $0.name.localizedCaseInsensitiveContains(search_text)
        }
    }
}

#Preview
{
    ImageListView()
        .environmentObject(StandardTemplateConstruct())
}
