//
//  Cards.swift
//  Industrial Builder
//
//  Created by Artem on 27.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct StandardCard: View
{
    @State private var is_presented = false
    
    let name: String
    let image_name: String
    
    let count_number: Int?
    
    let color: Color
    
    public init(name: String, count_number: Int? = nil, image_name: String, color: Color)
    {
        self.name = name
        self.count_number = count_number
        self.image_name = image_name
        self.color = color
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {
                Rectangle()
                    .foregroundColor(color)
                    .overlay(alignment: .trailing)
                    {
                        Image(systemName: image_name)
                            .fontWeight(.bold)
                            .font(.system(size: 96))
                        #if os(macOS)
                            .foregroundColor(Color(NSColor.quaternaryLabelColor))
                        #else
                            .foregroundColor(Color(UIColor.quaternaryLabel))
                        #endif
                            .padding()
                            .offset(x: 40, y: 20)
                    }
                    .overlay(alignment: .leading)
                    {
                        VStack(spacing: 0)
                        {
                            Text(name)
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .overlay(alignment: .topTrailing)
                    {
                        if count_number != nil
                        {
                            if count_number! > 0
                            {
                                Text("\(count_number!)")
                                    .fontWeight(.bold)
                                    .font(.system(size: 28, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .offset(y: -6)
                            }
                        }
                    }
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .shadow(radius: 8)
    }
}

struct StandardNavigationCard<Content: View>: View
{
    let name: String
    let image_name: String
    
    let count_number: Int?
    
    let color: Color
    
    let link_view: () -> Content
    
    public init(name: String, count_number: Int? = nil, image_name: String, color: Color, link_view: @escaping () -> Content)
    {
        self.name = name
        self.count_number = count_number
        self.image_name = image_name
        self.color = color
        
        self.link_view = link_view
    }
    
    var body: some View
    {
        NavigationLink(destination: link_view)
        {
            StandardCard(name: name, count_number: count_number, image_name: image_name, color: color)
        }
        .buttonStyle(.borderless)
    }
}

struct StandardSheetCard<Content: View>: View
{
    @State private var is_presented = false
    
    let name: String
    let image_name: String
    
    let count_number: Int?
    let color: Color
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    public init(name: String, count_number: Int? = nil, image_name: String, color: Color, @ViewBuilder content: @escaping (_ is_presented: Binding<Bool>) -> Content)
    {
        self.name = name
        self.image_name = image_name
        self.count_number = count_number
        self.color = color
        
        self.content = content
    }
    
    var body: some View
    {
        StandardCard(name: name, count_number: count_number, image_name: image_name, color: color)
            .onTapGesture
            {
                is_presented = true
            }
            .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
    }
}

struct ImageCard<Content: View>: View
{
    @Binding var image: UIImage
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
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
        .background
        {
            Rectangle()
                .foregroundStyle(.regularMaterial)
                .shadow(radius: 8)
        }
        .frame(height: 192)
        .onTapGesture
        {
            is_presented.toggle()
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
        .contextMenu
        {
            Button(role: .destructive, action: delete_image)
            {
                Label("Delete", systemImage: "xmark")
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
            .popover(isPresented: $is_presented, arrowEdge: .trailing, content: { content($is_presented) })
        #else
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture
            {
                is_presented.toggle()
            }
            .popover(isPresented: $is_presented, arrowEdge: .trailing, content: { content($is_presented) })
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
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
            }
        }
        .background
        {
            Rectangle()
                .foregroundStyle(.regularMaterial)
                .shadow(radius: is_selected ? 4 : 0)
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .frame(width: 64, height: 64)
        .help(name)
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
                .shadow(radius: 8)
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
        .frame(height: 192)
        .onTapGesture
        {
            is_presented.toggle()
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
        .contextMenu
        {
            Button(role: .destructive, action: delete_listing)
            {
                Label("Delete", systemImage: "xmark")
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
            ObjectSceneView(scene: scene)
                .disabled(true)
        }
        .buttonStyle(.borderless)
        .background(.regularMaterial)
        .sheet(isPresented: $is_presented, content: { content($is_presented).fitted() })
        .frame(height: 192)
        #if !os(visionOS)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(radius: 8)
        #else
        .glassBackgroundEffect()
        #endif
        .overlay(alignment: .bottomTrailing)
        {
            Text(URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent)
                .padding(8)
                #if os(macOS)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
                #else
                .foregroundColor(Color(UIColor.secondaryLabel))
                #endif
                .background(.bar)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(8)
        }
        .contextMenu
        {
            Button(role: .destructive, action: delete_scene)
            {
                Label("Delete", systemImage: "xmark")
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
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
        }
        .buttonStyle(.borderless)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(width: 64, height: 64)
        .shadow(radius: is_selected ? 4 : 0)
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
    }
    
    private func selecttion_toggle()
    {
        is_selected.toggle()
    }
}

struct KinematicCard<Content: View>: View
{
    let group: KinematicGroup
    
    let link_view: () -> Content
    
    public init(group: KinematicGroup, link_view: @escaping () -> Content)
    {
        self.group = group
        
        self.link_view = link_view
    }
    
    var body: some View
    {
        NavigationLink(destination: link_view)
        {
            VStack(spacing: 0)
            {
                ZStack
                {
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                        .overlay(alignment: .center)
                        {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                                .fontWeight(.bold)
                                .font(.system(size: 96))
                            #if os(macOS)
                                .foregroundColor(Color(NSColor.quaternaryLabelColor).opacity(0.25))
                            #else
                                .foregroundColor(Color(UIColor.quaternaryLabel).opacity(0.25))
                            #endif
                                .padding()
                                .offset(x: 40, y: 20)
                        }
                        .overlay(alignment: .topLeading)
                        {
                            VStack(spacing: 0)
                            {
                                Text(group.name)
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondary)
                                    .padding(6)
                            }
                        }
                        .overlay(alignment: .bottomLeading)
                        {
                            Text(group.type.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary.opacity(0.75))
                                .padding(6)
                        }
                }
                .frame(minWidth: 96, minHeight: 96)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .shadow(radius: 8)
        }
        .buttonStyle(.borderless)
    }
}

#Preview
{
    VStack(spacing: 0)
    {
        StandardCard(name: "Name", image_name: "gearshape.2.fill", color: .gray)
            .frame(width: 256)
            .padding(.bottom)
        
        StandardCard(name: "Name", count_number: 2, image_name: "cylinder.fill", color: .mint)
            .frame(width: 256)
    }
    .padding()
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

#Preview
{
    KinematicCard(group: KinematicGroup(name: "Name", type: .portal))
    {
        EmptyView()
    }
    .frame(width: 96, height: 96)
    .padding()
}
