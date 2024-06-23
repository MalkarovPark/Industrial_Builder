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
            .sheet(isPresented: $is_presented, content: {
                content($is_presented)
            })
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
        .sheet(isPresented: $is_presented, content: { content($is_presented) })
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
            /*.contextMenu
            {
                Button(role: .destructive, action: delete_image)
                {
                    Label("Delete", systemImage: "xmark")
                }
            }*/
        #else
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture
            {
                is_presented.toggle()
            }
            .popover(isPresented: $is_presented, arrowEdge: .trailing, content: { content($is_presented) })
            /*.contextMenu
            {
                Button(role: .destructive, action: delete_image)
                {
                    Label("Delete", systemImage: "xmark")
                }
            }*/
        #endif
    }
    
    /*func delete_image()
    {
        images.remove(at: images.firstIndex(of: image) ?? 0)
    }*/
}

struct SelectImageCard: View
{
    @Binding var image: UIImage
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    @State var is_selected = false
    
    let on_select: () -> ()
    let on_deselect: () -> ()
    
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
            
            if is_selected
            {
                on_select()
            }
            else
            {
                on_deselect()
            }
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
                .foregroundStyle(.white)
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
        .sheet(isPresented: $is_presented, content: { content($is_presented) })
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
        .sheet(isPresented: $is_presented, content: { content($is_presented) })
        .frame(height: 192)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(radius: 8)
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
    @Binding var scene: SCNScene
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let name: String
    
    @State var is_selected = false
    @State var is_main = false
    
    let on_select: () -> ()
    let on_deselect: () -> ()
    
    let on_main_set: () -> ()
    let on_main_unset: () -> ()
    
    public init(scene: Binding<SCNScene>, name: String, is_selected: Bool = false, is_main: Bool = false, on_select: @escaping () -> Void = {}, on_deselect: @escaping () -> Void = {}, on_main_set: @escaping () -> Void = {}, on_main_unset: @escaping () -> Void = {})
    {
        self._scene = scene
        self.name = name
        self.is_selected = is_selected
        self.is_main = is_main
        self.on_select = on_select
        self.on_deselect = on_deselect
        self.on_main_set = on_main_set
        self.on_main_unset = on_main_unset
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
            if !is_main
            {
                Button(role: .destructive, action: pin_toggle)
                {
                    Label("Set as main", systemImage: "pin")
                }
            }
            else
            {
                Button(role: .destructive, action: pin_toggle)
                {
                    Label("Unset as main", systemImage: "pin.slash")
                }
            }
            
            /*
             Toggle(isOn: $is_main)
             {
                 Label("Main", systemImage: "pin")
             }
             */
        }
    }
    
    private func selecttion_toggle()
    {
        is_selected.toggle()
        
        if is_selected
        {
            on_select()
        }
        else
        {
            on_deselect()
            
            if is_main
            {
                is_selected = false
                on_main_unset()
            }
        }
    }
    
    private func pin_toggle()
    {
        is_main.toggle()
        
        if is_main
        {
            on_main_set()
        }
        else
        {
            on_main_unset()
        }
        
        if !is_selected
        {
            is_selected.toggle()
            on_select()
        }
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
        SelectImageCard(image: .constant(UIImage()), name: "Image", on_select: {}, on_deselect: {})
            .padding(.trailing)
        
        SelectSceneCard(scene: .constant(SCNScene()), name: "Image", on_select: {}, on_deselect: {}, on_main_set: {}, on_main_unset: {})
    }
    .padding()
}
