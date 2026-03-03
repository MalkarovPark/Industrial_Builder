//
//  PartModelView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct PartModelView: View
{
    let entity: Entity?
    
    @State private var preview_entity: Entity?
    
    @Binding var is_pan: Bool
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    
    @StateObject var workspace = Workspace()
    @StateObject var previewed_part = Part(name: "preview", entity: Entity())
    
    var body: some View
    {
        ZStack
        {
            RealityView
            { content in
                scene_content = content
                scene_content?.camera = .virtual
                
                workspace.place_entity(to: content)
                workspace.add_part(previewed_part)
                
                place_entity(entity)
            }
            .realityViewCameraControls(is_pan ? .pan : .orbit)
            .gesture(
                TapGesture()
                    .onEnded
                    {
                        workspace.focus(on: previewed_part.model_entity)
                    }
            )
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            preview_entity = new_entity
            previewed_part.model_entity?.addChild(new_entity)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_part.model_entity)
        }
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        
        place_entity(new_entity)
    }
}
