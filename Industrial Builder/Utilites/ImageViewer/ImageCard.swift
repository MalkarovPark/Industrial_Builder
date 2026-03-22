//
//  ImageCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

import IndustrialKit

struct ImageCard<Content: View>: View
{
    let image_item: ImageItem
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var hovered = false
    
    var body: some View
    {
        Button { is_presented.toggle() }
        label:
        {
            ZStack
            {
                #if os(macOS)
                Image(nsImage: image_item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(alignment: .bottomLeading)
                    {
                        Text(image_item.name)
                            .padding(8)
                            .background
                            {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .padding(8)
                    }
                #else
                Image(uiImage: image_item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(alignment: .bottomLeading)
                    {
                        Text(image_item.name)
                            .padding(8)
                            .background
                            {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .padding(8)
                    }
                #endif
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .offset(y: hovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .background
        {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .blur(radius: 16)
                .opacity(0.2)
        }
        .frame(height: 192)
        .onHover
        { hovered in
            withAnimation(.easeInOut(duration: 0.2))
            {
                self.hovered = hovered
            }
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .contextMenu
        {
            Button(role: .destructive, action: delete_image)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func delete_image()
    {
        base_stc.image_items.removeAll { $0 == image_item }
        document_handler.document_update_changersges()
    }
}

#Preview
{
    ImageCard(image_item: ImageItem(name: "Image", image: UIImage()))
    { is_presented in
        EmptyView()
    }
    .padding()
}
