//
//  AppView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 11.10.2023.
//

import SwiftUI
import IndustrialKit

struct AppView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var document: STCDocument
    
    @State private var is_editors_presented = [false, false, false]
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                Text("Robotic Complex Workspace")
                    .font(.title2)
                    .padding()
                
                LazyVGrid(columns: columns, spacing: 24)
                {
                    FunctionCard(is_presented: $is_editors_presented[0], name: "Robot", image_name: "r.square.fill", color: .green, count: 0)
                    {
                        RobotModulesEditor(is_presented: $is_editors_presented[0])
                    }
                    
                    FunctionCard(is_presented: $is_editors_presented[1], name: "Tool", image_name: "hammer.fill", color: .teal, count: base_stc.tool_modules.count)
                    {
                        ToolModulesEditor(document: $document, is_presented: $is_editors_presented[1])
                    }
                    
                    FunctionCard(is_presented: $is_editors_presented[2], name: "Changer", image_name: "wand.and.rays", color: .indigo, count: base_stc.changer_modules.count)
                    {
                        ChangerModulesEditor(document: $document, is_presented: $is_editors_presented[2])
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .modifier(WindowFramer())
    }
}

struct FunctionCard<Content: View>: View
{
    //@Environment(\.openWindow) var openWindow
    @Binding var is_presented: Bool
    
    let name: String
    let image_name: String
    let color: Color
    let count: Int
    
    let content: () -> Content
    
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
                content()
            })
        }
        #if os(visionOS)
        .frame(depth: 16)
        #endif
        .shadow(radius: 8.0)
        //.padding()
    }
}

/*struct EditorView: View
{
    var body: some View
    {
        
    }
}*/

#Preview
{
    AppView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}
