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
            provider.loadObject(ofClass: UIImage.self)
            { image, error in
                if let image = image as? UIImage
                {
                    DispatchQueue.main.async
                    {
                        base_stc.images.append(image)
                        app_state.document_update_gallery()
                        //document.images.append(image)
                        //print(image.name())
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
