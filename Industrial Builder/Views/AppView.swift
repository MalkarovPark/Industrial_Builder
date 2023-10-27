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
                    FunctionCard(name: "Robot", image_name: "r.square.fill", color: .green, count: 0)
                    { is_presented in
                        RobotModulesEditor(is_presented: is_presented)
                    }
                    
                    FunctionCard(name: "Tool", image_name: "hammer.fill", color: .teal, count: base_stc.tool_modules.count)
                    { is_presented in
                        ToolModulesEditor(document: $document, is_presented: is_presented)
                    }
                    
                    FunctionCard(name: "Changer", image_name: "wand.and.rays", color: .indigo, count: base_stc.changer_modules.count)
                    { is_presented in
                        ChangerModulesEditor(document: $document, is_presented: is_presented)
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

#Preview
{
    AppView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}
