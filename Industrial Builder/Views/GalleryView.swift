//
//  GalleryView.swift
//  Industrial Builder
//
//  Created by Artem on 09.10.2023.
//

import SwiftUI

struct GalleryView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    
    @State private var is_targeted = false
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            if base_stc.images.count > 0
            {
                ScrollView(.horizontal)
                {
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 240))], spacing: 16)
                    {
                        ForEach(base_stc.images, id: \.self)
                        { image in
                            ImageCard(image: image)
                        }
                    }
                }
            }
            else
            {
                NoView(label: "No Images")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            provider.loadItem(forTypeIdentifier: "public.image", options: nil)
            { (item, error) in
                DispatchQueue.main.async
                {
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
                            app_state.document_update_gallery()
                            base_stc.images_files_names.append(file_name)
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
    GalleryView()
        .environmentObject(StandardTemplateConstruct())
}
