//
//  Cards.swift
//  Industrial Builder
//
//  Created by Artem on 27.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKitUI

struct ImageCard<Content: View>: View
{
    @Binding var image: UIImage
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var hovered = false
    
    var body: some View
    {
        ZStack
        {
            #if os(macOS)
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(alignment: .bottomTrailing)
                {
                    Text(name)
                        .padding(8)
                        .background
                        {
                            Rectangle()
                                .foregroundStyle(.thinMaterial)
                        }
                }
            #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture
                {
                    is_presented.toggle()
                }
                .overlay(alignment: .bottomTrailing)
                {
                    Text(name)
                        .padding(8)
                        .background
                        {
                            Rectangle()
                                .foregroundStyle(.thinMaterial)
                        }
                }
            #endif
        }
        .offset(y: hovered ? -2 : 0)
        .background
        {
            Rectangle()
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
        .onTapGesture
        {
            is_presented.toggle()
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
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
        base_stc.images_files_names.remove(at: base_stc.images.firstIndex(of: image) ?? 0)
        base_stc.images.remove(at: base_stc.images.firstIndex(of: image) ?? 0)
        document_handler.document_update_images()
    }
}

struct SimpleImageCard<Content: View>: View
{
    @State var image: UIImage
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    var body: some View
    {
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture
            {
                is_presented.toggle()
            }
            .sheet(isPresented: $is_presented, content: { content($is_presented).modifier(ViewCloseButton(is_presented: $is_presented)) })
        #else
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture
            {
                is_presented.toggle()
            }
            .sheet(isPresented: $is_presented, content: { content($is_presented).modifier(ViewCloseButton(is_presented: $is_presented)) })
        #endif
    }
}

struct SelectImageCard: View
{
    let image: UIImage
    let name: String
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var is_selected: Bool
    
    public init(image: UIImage, name: String, is_selected: Binding<Bool>, on_select: @escaping () -> Void = {}, on_deselect: @escaping () -> Void = {})
    {
        self.image = image
        self.name = name
        self._is_selected = is_selected
    }
    
    var body: some View
    {
        ZStack
        {
            #if os(macOS)
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #endif
        }
        .overlay
        {
            if is_selected
            {
                ZStack
                {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.primary)
                }
                #if os(macOS)
                .frame(width: 40, height: 40)
                #else
                .frame(width: 48, height: 48)
                #endif
                .background(.ultraThinMaterial)
            }
        }
        .background
        {
            Rectangle()
                .foregroundStyle(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: is_selected ? 4 : 0)
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .help(name)
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ListingCard<Content: View>: View
{
    @Binding var code: String
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var hovered = false
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
            #if !os(visionOS)
                .foregroundStyle(.white)
            #else
                .foregroundStyle(.bar)
            #endif
                .overlay(alignment: .topLeading)
                {
                    Text(code)
                }
                .overlay(alignment: .bottomTrailing)
                {
                    Text(name)
                        .padding(8)
                        .background
                        {
                            Rectangle()
                                .foregroundStyle(.thinMaterial)
                        }
                }
        }
        .offset(y: hovered ? -2 : 0)
        .background
        {
            Rectangle()
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
        .onTapGesture
        {
            is_presented.toggle()
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
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
        base_stc.listings_files_names.remove(at: base_stc.listings.firstIndex(of: code) ?? 0)
        base_stc.listings.remove(at: base_stc.listings.firstIndex(of: code) ?? 0)
        document_handler.document_update_listings()
    }
}

struct SceneCard<Content: View>: View
{
    @Binding var scene: SCNScene
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    var body: some View
    {
        Button(action: { is_presented = true })
        {
            GlassBoxCard(title: name, node: scene.rootNode)
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
        .frame(height: 192)
        .contextMenu
        {
            Button(role: .destructive, action: delete_scene)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func delete_scene()
    {
        base_stc.scenes_files_names.remove(at: base_stc.scenes.firstIndex(of: scene) ?? 0)
        base_stc.scenes.remove(at: base_stc.scenes.firstIndex(of: scene) ?? 0)
        document_handler.document_update_scenes()
    }
}

struct SelectSceneCard: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let scene: SCNScene
    let name: String
    
    @Binding var is_selected: Bool
    @Binding var is_main: Bool
    
    public init(scene: SCNScene, name: String, is_selected: Binding<Bool>, is_main: Binding<Bool>, on_main_set: @escaping () -> Void = {}, on_main_unset: @escaping () -> Void = {})
    {
        self.scene = scene
        self.name = name
        self._is_selected = is_selected
        self._is_main = is_main
    }
    
    var body: some View
    {
        ZStack
        {
            ObjectSceneView(scene: scene)
                .disabled(true)
                .overlay
                {
                    if is_selected
                    {
                        ZStack
                        {
                            Image(systemName: is_main ? "diamond" : "checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.primary)
                        }
                        #if os(macOS)
                        .frame(width: 40, height: 40)
                        #else
                        .frame(width: 48, height: 48)
                        #endif
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
        }
        .buttonStyle(.borderless)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: is_selected ? 4 : 0)
        .scaleEffect(is_selected ? 1 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .help(name)
        .onTapGesture
        {
            selecttion_toggle()
        }
        .contextMenu
        {
            Toggle("Is Main Scene", isOn: $is_main)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func selecttion_toggle()
    {
        is_selected.toggle()
    }
}

#Preview
{
    ImageCard(image: .constant(UIImage()), name: "Image")
    { is_presented in
        EmptyView()
    }
    .padding()
}

#Preview
{
    SceneCard(scene: .constant(SCNScene()), name: "Name")
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
    .padding()
}

#Preview
{
    HStack(spacing: 0)
    {
        SelectImageCard(image: UIImage(), name: "Image", is_selected: .constant(true), on_select: {}, on_deselect: {})
            .padding(.trailing)
        
        SelectSceneCard(scene: SCNScene(), name: "Image", is_selected: .constant(true), is_main: .constant(false), on_main_set: {}, on_main_unset: {})
    }
    .padding()
}
