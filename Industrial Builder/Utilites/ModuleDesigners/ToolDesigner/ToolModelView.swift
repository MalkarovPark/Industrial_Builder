//
//  ToolModelView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct ToolModelView: View
{
    let entity: Entity?
    
    @State private var preview_entity: Entity?
    
    @StateObject var workspace = Workspace()
    @StateObject var previewed_tool = Tool(name: "preview", entity: Entity())
    
    @Binding var is_pan: Bool
    
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    
    var body: some View
    {
        ZStack
        {
            RealityView
            { content in
                scene_content = content
                scene_content?.camera = .virtual
                
                workspace.place_entity(to: content)
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
            
            FloatingView(alignment: .bottomTrailing)
            {
                OperationControl(tool: previewed_tool)
                    .padding(8)
            }
            .padding(10)
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
        .onDisappear
        {
            workspace.delete_tool(name: "preview")
            preview_entity?.removeFromParent()
            preview_entity = nil
            workspace.remove_entity(from: scene_content!)
        }
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            //workspace.select_tool(name: "preview")
            preview_entity = new_entity
            previewed_tool.model_entity?.addChild(new_entity)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_tool.model_entity)
        }
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        
        place_entity(new_entity)
    }
}
