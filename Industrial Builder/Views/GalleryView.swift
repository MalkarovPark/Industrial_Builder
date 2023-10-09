//
//  GalleryView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 09.10.2023.
//

import SwiftUI

struct GalleryView: View
{
    #if os(macOS)
    @State private var images: [NSImage] = []
    #else
    @State private var images: [UIImage] = []
    #endif
    @State private var is_targeted = false
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            if images.count > 0
            {
                ScrollView(.horizontal)
                {
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 240))], spacing: 16)
                    {
                        ForEach(images, id: \.self)
                        { image in
                            #if os(macOS)
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            #else
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            #endif
                        }
                    }
                }
            }
            else
            {
                VStack(spacing: 0)
                {
                    Text("None")
                        .padding()
                }
                .frame(maxWidth: .infinity, minHeight: 240)
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
                        .background(.thinMaterial)
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
        #if os(macOS)
        for provider in providers
        {
            provider.loadObject(ofClass: NSImage.self)
            { image, error in
                if let image = image as? NSImage
                {
                    DispatchQueue.main.async
                    {
                        images.append(image)
                    }
                }
            }
        }
        #else
        for provider in providers
        {
            provider.loadObject(ofClass: UIImage.self)
            { image, error in
                if let image = image as? UIImage
                {
                    DispatchQueue.main.async
                    {
                        images.append(image)
                    }
                }
            }
        }
        #endif
        return true
    }
}

#Preview
{
    GalleryView()
}
