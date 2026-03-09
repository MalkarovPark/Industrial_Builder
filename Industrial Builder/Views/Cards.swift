//
//  Cards.swift
//  Industrial Builder
//
//  Created by Artem on 27.10.2023.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct ImageCard<Content: View>: View
{
    let image_item: ImageItem
    
    let content: (_ isPresented: Binding<Bool>) -> Content
    
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
                    .onTapGesture
                {
                    is_presented.toggle()
                }
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
        document_handler.document_update_images()
    }
}

struct ListingCard<Content: View>: View
{
    let listing_item: ListingItem
    
    let content: (_ isPresented: Binding<Bool>) -> Content
    
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
                Rectangle()
                #if !os(visionOS)
                    .foregroundStyle(.white)
                #else
                    .foregroundStyle(.black.opacity(0.25))
                #endif
                    .overlay(alignment: .topLeading)
                {
                    Text(listing_item.text)
                    #if os(macOS)
                        .font(.custom("Menlo", size: 10))
                    #else
                        .font(.custom("Menlo", size: 14))
                    #endif
                        .foregroundStyle(.secondary)
                }
                .overlay(alignment: .bottomLeading)
                {
                    Text(listing_item.name)
                        .padding(8)
                        .background
                        {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .foregroundStyle(.thinMaterial)
                        }
                        .padding(8)
                }
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
            Button(role: .destructive, action: delete_listing)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func delete_listing()
    {
        base_stc.listing_items.removeAll { $0 == listing_item }
        document_handler.document_update_listings()
    }
}

struct SceneCard<Content: View>: View
{
    let entity_item: EntityItem
    
    let content: (_ isPresented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        Button(action: { is_presented = true })
        {
            GlassBoxCard(
                title: entity_item.name,
                entity: entity_item.entity,
                vertical_repostion: true
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .frame(height: 192)
        .contextMenu
        {
            Button(role: .destructive)
            {
                delete_scene()
            }
            label:
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func delete_scene()
    {
        base_stc.entity_items.removeAll { $0 == entity_item }
        document_handler.document_update_scenes()
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

#Preview
{
    SceneCard(entity_item: EntityItem(name: "Entity", entity: ModelEntity(mesh: .generateBox(size: 1.0, cornerRadius: 0.1), materials: [SimpleMaterial(color: .white, isMetallic: false)])))
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
    .padding()
}
