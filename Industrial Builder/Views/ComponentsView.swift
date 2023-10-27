//
//  ComponentsView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 25.10.2023.
//

import SwiftUI

struct ComponentsView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var document: STCDocument
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        NavigationStack
        {
            ScrollView(.vertical)
            {
                VStack(spacing: 0)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        NaviagtionCard(name: "Models", image_name: "cylinder.fill", color: .mint, count: 0)
                        {
                            EmptyView()
                        }
                        
                        NaviagtionCard(name: "Kinematics", image_name: "point.3.connected.trianglepath.dotted", color: .pink, count: base_stc.tool_modules.count)
                        {
                            KinematicsListView()
                        }
                    }
                    .padding(20)
                }
            }
        }
        .modifier(WindowFramer())
    }
}

struct NaviagtionCard<Content: View>: View
{
    let name: String
    let image_name: String
    let color: Color
    let count: Int
    let link_view: () -> Content
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            NavigationLink(destination: link_view)
            {
                Rectangle()
                    .foregroundColor(color)
            }
            .buttonStyle(.plain)
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
        }
        #if os(visionOS)
        .frame(depth: 16)
        #endif
        .shadow(radius: 8)
    }
}

struct ComponentCard<Content: View>: View
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
                    .overlay(alignment: .bottomTrailing)
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

#Preview
{
    ComponentsView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    ComponentCard(name: "Name", image_name: "gearshape.2.fill", color: .gray)
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
}

#Preview
{
    NaviagtionCard(name: "Models", image_name: "cylinder.fill", color: .mint, count: 0)
    {
        EmptyView()
    }
}
