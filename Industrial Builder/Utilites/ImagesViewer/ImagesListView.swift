//
//  ImagesView.swift
//  Industrial Builder
//
//  Created by Artem on 29.03.2024.
//

import SwiftUI
import IndustrialKit

struct ImagesListView: View
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
            if base_stc.images.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.images, id: \.self)
                        { image in
                            ImageCard(image: image)
                            { is_presented in
                                ImageView(image: image)
                                    //.modifier(WindowFramer())
                                    .modifier(ViewCloseButton(is_presented: is_presented))
                                    .frame(maxWidth: 800)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            else
            {
                NoView(label: "No Images")
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
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .onDrop(of: [.image], isTargeted: $is_targeted)
        { providers in
            perform_drop(providers: providers)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(WindowFramer())
        .toolbar
        {
            Button(action: { clear_message_presented.toggle() })
            {
                Image(systemName: "eraser")
            }
            .confirmationDialog(Text("Remove all images?"), isPresented: $clear_message_presented)
            {
                Button("Remove", role: .destructive)
                {
                    base_stc.images.removeAll()
                    base_stc.images_files_names.removeAll()
                    document_handler.document_update_gallery()
                }
            }
            
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            .fileImporter(isPresented: $load_panel_presented,
                                  allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: import_images)
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
                            base_stc.images.append(image)
                            base_stc.images_files_names.append(file_name)
                            document_handler.document_update_gallery()
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
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData)
                    {
                        base_stc.images.append(image)
                        base_stc.images_files_names.append(url.lastPathComponent)
                    }
                    url.stopAccessingSecurityScopedResource()
                }
                document_handler.document_update_gallery()
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
    ImagesListView()
        .environmentObject(StandardTemplateConstruct())
}
