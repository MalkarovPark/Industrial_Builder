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
    
    @StateObject var previewed_tool: Tool
    
    @State private var previewed_entity: Entity?
    
    #if os(macOS) || os(iOS)
    @StateObject var workspace: Workspace
    
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
        .onDisappear
        {
            #if !os(visionOS)
            workspace.delete_tool(name: "preview")
            #endif
            previewed_entity?.removeFromParent()
            previewed_entity = nil
            #if !os(visionOS)
            workspace.remove_entity(from: scene_content!)
            #endif
        }
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            //workspace.select_tool(name: "preview")
            previewed_entity = new_entity
            previewed_tool.model_entity?.addChild(new_entity)
            
            previewed_tool.model_controller.connect_entities(of: new_entity)
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
        previewed_entity?.removeFromParent()
        place_entity(new_entity)
    }
}
