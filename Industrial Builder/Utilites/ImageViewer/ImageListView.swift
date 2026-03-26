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
                        ForEach(base_stc.image_items)
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
                .animation(.spring(), value: base_stc.image_items)
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
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
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
                            
                            document_handler.drop_document_update_changersges()
                        }
                    }
                }
            }
        }
        return true
    }
    
    func import_images(_ res: Result<[URL], Error>)
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
                document_handler.document_update_images()
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
    ImageListView()
        .environmentObject(StandardTemplateConstruct())
}
