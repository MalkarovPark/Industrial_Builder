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
    
    @State private var is_targeted = false
    
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
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            /*provider.loadInPlaceFileRepresentation(forTypeIdentifier: "public.image")
            { (fileURL, isWritable, error) in
                DispatchQueue.main.async
                {
                    if let fileURL = fileURL
                    {
                        if let image_data = try? Data(contentsOf: fileURL)
                        {
                            guard let image = UIImage(data: image_data)
                            else
                            {
                                return
                            }
                            base_stc.images.append(image)
                            base_stc.images_files_names.append(fileURL.lastPathComponent)
                            app_state.document_update_gallery()
                        }
                    }
                    else if let error = error
                    {
                        print(error.localizedDescription)
                    }
                }
            }*/
            
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
                            app_state.document_update_gallery()
                        }
                    }
                }
            }
        }
        return true
    }
}

#Preview
{
    ImagesListView()
        .environmentObject(StandardTemplateConstruct())
}
