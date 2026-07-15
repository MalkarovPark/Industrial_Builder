//
//  PartModelView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct PartModelView: View
{
    let entity: Entity?
    
    #if os(macOS) || os(iOS)
    @State private var previewed_entity: Entity?
    
    @StateObject var workspace = Workspace()
    @StateObject var previewed_part = Part(name: "preview", entity: Entity())
    
    @Binding var is_pan: Bool
    
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    #else
    @State private var view_id = UUID()
    #endif
    
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
            .ignoresSafeArea(.container, edges: .vertical)
            #else
            DesignRealityView(entity: entity)
                .id(view_id)
            #endif
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
    }
    
    #if os(macOS) || os(iOS)
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            previewed_entity = new_entity
            previewed_part.model_entity?.addChild(new_entity)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_part.model_entity)
        }
    }
    #endif
    
    private func update_entity(_ new_entity: Entity?)
    {
        #if os(macOS) || os(iOS)
        previewed_entity?.removeFromParent()
        place_entity(new_entity)
        #else
        view_id = UUID()
        #endif
    }
}
