//
//  GalleryView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 09.10.2023.
//

import SwiftUI

struct GalleryView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
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
                            ImageCard(document: $document, image: image)
                        }
                    }
                }
            }
            else
            {
                VStack(spacing: 0)
                {
                    Text("No Images")
                        .font(.largeTitle)
                    #if os(macOS)
                        .foregroundColor(Color(NSColor.quaternaryLabelColor))
                    #else
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                    #endif
                        .padding(16)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.6)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                }
                .frame(maxWidth: .infinity, minHeight: 240)
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
                        document.images.append(image)
                        //print(image.name())
                    }
                }
            }
        }
        
        //document.images = base_stc.images
        
        return true
    }
}

struct ImageCard: View
{
    @Binding var document: STCDocument
    
    @State var image: UIImage
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contextMenu
            {
                Button(role: .destructive, action: delete_image)
                {
                    Label("Delete", systemImage: "xmark")
                }
            }
        #else
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contextMenu
            {
                Button(role: .destructive, action: delete_image)
                {
                    Label("Delete", systemImage: "xmark")
                }
            }
        #endif
    }
    
    func delete_image()
    {
        base_stc.images.remove(at: base_stc.images.firstIndex(of: image) ?? 0)
        document.images = base_stc.images
    }
}

#Preview
{
    GalleryView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}
