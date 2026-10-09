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
    
    @State private var previewed_entity: Entity?
    
    @State private var position_pane_is_expanded = false
    
    #if os(macOS) || os(iOS)
    @StateObject var workspace: Workspace
    
    @Binding var is_pan: Bool
    
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
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
            #endif
            
            FloatingView(alignment: .bottomTrailing)
            {
                VStack(spacing: 8)
                {
                    PositionPane(
                        robot: previewed_robot,
                        on_expand: { withAnimation { position_pane_is_expanded = true } },
                        on_collapse: { withAnimation { position_pane_is_expanded = false } }
                    )
                    .zIndex(1)
                    
                    if !position_pane_is_expanded
                    {
                        PositionControl(robot: previewed_robot)
                            .frame(width: 120)
                        #if !os(visionOS)
                            .transition(.scale(scale: 0, anchor: .center).combined(with: .opacity))
                        #else
                            .transition(
                                .asymmetric(
                                    insertion: .identity,
                                    removal: .offset(x: 0, y: -4) //8)
                                        .combined(with: .scale(scale: 0, anchor: .center))
                                        .combined(with: .opacity)
                                )
                            )
                            .offset(z: position_pane_is_expanded ? -8 : 0)
                        #endif
                            .padding(10)
                    }
                }
                .padding([.horizontal, .bottom], position_pane_is_expanded ? 12 : 4)
                .padding(.top, position_pane_is_expanded ? 12 : 16)
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
            //workspace.select_robot(name: "preview")
            previewed_entity = new_entity
            previewed_robot.model_entity?.addChild(new_entity)
            
            #if os(macOS) || os(iOS)
            previewed_robot.model_controller.connect_entities(of: new_entity)
            #else
            previewed_robot.hide_position_pointer()
            previewed_robot.hide_working_area()
            previewed_robot.extend_entity_preparation(new_entity)
            previewed_robot.show_position_pointer()
            previewed_robot.show_working_area()
            #endif
            
            previewed_robot.update_model()
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
        previewed_entity?.removeFromParent()
        place_entity(new_entity)
    }
}
