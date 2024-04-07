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
            //Rectangle()
                //.foregroundStyle(.regularMaterial)
            #if os(macOS)
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 8)
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
            #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture
                {
                    is_presented.toggle()
                }
            #endif
        }
        .frame(height: 192)
        .sheet(isPresented: $is_presented, content: { content($is_presented) })
        //.shadow(radius: 8)
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
        document_handler.document_update_gallery()
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
        .sheet(isPresented: $is_presented, content: { content($is_presented) })
        .onTapGesture
        {
            is_presented.toggle()
        }
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
        //base_stc.images_files_names.remove(at: base_stc.images.firstIndex(of: image) ?? 0)
        //base_stc.images.remove(at: base_stc.images.firstIndex(of: image) ?? 0)
        //document_handler.document_update_gallery()
    }
}

struct SimpleImageCard<Content: View>: View
{
    //@Binding var images: [UIImage]
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

struct ModelCard<Content: View>: View
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
        .overlay(alignment: .bottomLeading)
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

#Preview
{
    StandardCard(name: "Name", image_name: "gearshape.2.fill", color: .gray)
        .frame(width: 256)
}

#Preview
{
    StandardCard(name: "Name", count_number: 2, image_name: "gearshape.2.fill", color: .gray)
        .frame(width: 256)
}

#Preview
{
    StandardSheetCard(name: "Name", count_number: 2, image_name: "gearshape.2.fill", color: .gray)
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    StandardNavigationCard(name: "Name", image_name: "cylinder.fill", color: .mint)
    {
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    ModelCard(scene: .constant(SCNScene()), name: "Name")
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}
