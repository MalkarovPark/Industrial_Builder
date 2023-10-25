//
//  KinematicsListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 25.10.2023.
//

import SwiftUI

struct KinematicsListView: View
{
    @State private var is_presented = [false, false, false]
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    KinematicCard(is_presented: $is_presented[0], name: "K1", image_name: "cylinder.fill", color: .gray)
                    {
                        KinematicEditorView(is_presented: $is_presented[0])
                    }
                }
                .padding(20)
            }
        }
        .toolbar
        {
            Button (action: {  })
            {
                Label("Add Kinematic", systemImage: "plus")
            }
        }
        .modifier(WindowFramer())
    }
}

struct KinematicCard<Content: View>: View
{
    //@Environment(\.openWindow) var openWindow
    @Binding var is_presented: Bool
    
    let name: String
    let image_name: String
    let color: Color
    
    let content: () -> Content
    
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
                        content()
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
    KinematicsListView()
}

#Preview
{
    KinematicCard(is_presented: .constant(true), name: "Name", image_name: "gearshape.2.fill", color: .gray)
    {
        EmptyView()
    }
    .frame(width: 256)
}
