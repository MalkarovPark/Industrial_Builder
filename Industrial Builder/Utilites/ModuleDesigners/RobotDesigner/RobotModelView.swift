//
//  RobotModelView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct RobotModelView: View
{
    let entity: Entity?
    
    @StateObject var previewed_robot: Robot
    
    #if os(macOS) || os(iOS)
    @State private var previewed_entity: Entity?
    
    @StateObject var workspace: Workspace
    
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
                workspace.add_robot(previewed_robot)
                
                place_entity(entity)
                
                //workspace.select_robot(name: "preview")
                previewed_robot.show_position_pointer()
                previewed_robot.show_working_area()
            }
            .realityViewCameraControls(is_pan ? .pan : .orbit)
            .gesture(
                TapGesture()
                    .onEnded
                    {
                        workspace.focus(on: previewed_robot.model_entity)
                    }
            )
            .ignoresSafeArea(.container, edges: .all)
            #else
            DesignRealityView(entity: previewed_robot.model_entity)
                .onAppear(perform: { place_entity(entity) })
                .id(view_id)
            #endif
            
            FloatingView(alignment: .bottomTrailing)
            {
                VStack(spacing: 8)
                {
                    PositionPane(robot: previewed_robot)
                    
                    PositionControl(robot: previewed_robot)
                }
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
            workspace.delete_robot(name: "preview")
            previewed_entity?.removeFromParent()
            previewed_entity = nil
            workspace.remove_entity(from: scene_content!)
        }
        #endif
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            #if os(macOS) || os(iOS)
            //workspace.select_robot(name: "preview")
            previewed_entity = new_entity
            #else
            previewed_robot.model_entity?.children.removeAll()
            #endif
            previewed_robot.model_entity?.addChild(new_entity)
        }
        
        #if os(macOS) || os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_robot.model_entity)
        }
        #endif
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        #if os(macOS) || os(iOS)
        previewed_entity?.removeFromParent()
        #else
        previewed_robot.model_entity?.children.removeAll()
        view_id = UUID()
        #endif
        
        place_entity(new_entity)
    }
}
