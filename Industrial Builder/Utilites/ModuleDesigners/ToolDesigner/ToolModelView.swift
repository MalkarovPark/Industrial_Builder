//
//  ToolModelView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct ToolModelView: View
{
    let entity: Entity?
    
    @State private var preview_entity: Entity?
    
    @StateObject var workspace: Workspace
    @StateObject var previewed_tool: Tool
    
    #if os(macOS) || os(iOS)
    @Binding var is_pan: Bool
    
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    #endif
    
    //@State private var scene_content: RealityViewContent?
    
    var body: some View
    {
        ZStack
        {
            #if os(macOS) || os(iOS)
            RealityView
            { content in
                scene_content = content
                scene_content?.camera = .virtual
                
                workspace.place_entity(in: content)
                workspace.add_tool(previewed_tool)
                
                place_entity(entity)
                
                //workspace.select_tool(name: "preview")
            }
            .realityViewCameraControls(is_pan ? .pan : .orbit)
            .gesture(
                TapGesture()
                    .onEnded
                    {
                        workspace.focus(on: previewed_tool.model_entity)
                    }
            )
            .ignoresSafeArea(.container, edges: .all)
            #else
            DesignRealityView(entity: previewed_tool.model_entity)
                .onAppear(perform: { place_entity(entity) })
            #endif
            
            FloatingView(alignment: .bottomTrailing)
            {
                OperationControl(tool: previewed_tool)
                    .padding(8)
            }
            .padding(7.8)
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
        #if !os(visionOS)
        .onDisappear
        {
            workspace.delete_tool(name: "preview")
            preview_entity?.removeFromParent()
            preview_entity = nil
            workspace.remove_entity(from: scene_content!)
        }
        #endif
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            //workspace.select_tool(name: "preview")
            preview_entity = new_entity
            previewed_tool.model_entity?.addChild(new_entity)
        }
        
        #if os(macOS) || os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_tool.model_entity)
        }
        #endif
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        
        place_entity(new_entity)
    }
}
