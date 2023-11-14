//
//  Cards.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 27.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct StandardNumericalCard<Content: View>: View
{
    @State private var is_presented = false
    
    let name: String
    let image_name: String
    let color: Color
    let count: Int
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {
                Rectangle()
                    .foregroundColor(color)
            }
            .frame(height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(alignment: .topLeading)
            {
                Text(name)
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
            }
            .overlay(alignment: .bottomLeading)
            {
                if count > 0
                {
                    Text("\(count)")
                        .fontWeight(.bold)
                        .font(.system(size: 48, design: .rounded))
                        #if os(macOS)
                        .foregroundColor(Color(NSColor.quaternaryLabelColor))
                        #else
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                        #endif
                        .padding()
                }
            }
            .overlay(alignment: .bottomTrailing)
            {
                Image(systemName: image_name)
                    .fontWeight(.bold)
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                    .shadow(radius: 8)
                    .padding()
            }
            .onTapGesture
            {
                is_presented = true
                //openWindow(id: "editor")
            }
            .sheet(isPresented: $is_presented, content: {
                content($is_presented)
            })
        }
        #if os(visionOS)
        .frame(depth: 16)
        #endif
        .shadow(radius: 8)
    }
}

struct StandardCard<Content: View>: View
{
    @State private var is_presented = false
    
    let name: String
    let image_name: String
    let color: Color
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {
                Rectangle()
                    .foregroundColor(color)
                    .overlay(alignment: .leading)
                    {
                        Text(name)
                            .font(.system(.title))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .overlay(alignment: .trailing)
                    {
                        Image(systemName: image_name)
                            .fontWeight(.bold)
                            .font(.system(size: 48))
                        #if os(macOS)
                            .foregroundColor(Color(NSColor.quaternaryLabelColor))
                        #else
                            .foregroundColor(Color(UIColor.quaternaryLabel))
                        #endif
                            .padding()
                    }
                    .onTapGesture
                    {
                        is_presented = true
                        //openWindow(id: "editor")
                    }
                    .sheet(isPresented: $is_presented, content: {
                        content($is_presented)
                    })
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        #if os(visionOS)
        .frame(depth: 16)
        #endif
        .shadow(radius: 8)
        //.padding()
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

struct ModelCard<Content: View>: View
{
    @Binding var node: SCNNode
    
    @State private var is_presented = false
    
    let name: String
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    var body: some View
    {
        Button(action: { is_presented = true })
        {
            ObjectSceneView(node: node)
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
            Text(name)
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
    }
}

#Preview
{
    StandardNumericalCard(name: "Name", image_name: "cube", color: .green, count: 2)
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    StandardCard(name: "Name", image_name: "gearshape.2.fill", color: .gray)
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    NaviagtionNumericalCard(name: "Name", image_name: "cylinder.fill", color: .mint, count: 0)
    {
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    ModelCard(node: .constant(SCNNode()), name: "Name")
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}
