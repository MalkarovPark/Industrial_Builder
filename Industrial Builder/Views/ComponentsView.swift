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
                            KinematicsListView()
                        }
                        
                        NaviagtionCard(name: "Kinematics", image_name: "point.3.connected.trianglepath.dotted", color: .pink, count: base_stc.tool_modules.count)
                        {
                            EmptyView()
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

#Preview
{
    ComponentsView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}
