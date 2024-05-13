//
//  KinematicEditorView.swift
//  Industrial Builder
//
//  Created by Artem on 23.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct KinematicEditorView: View
{
    @Binding var group: KinematicGroup
    @EnvironmentObject var app_state: AppState
    
    @State private var pointer_location: [Float] = [0, 0, 0]
    @State private var pointer_rotation: [Float] = [0, 0, 0]
    @State private var show_inspector = true
    
    private let viewed_scene = SCNScene(named: "KinematicComponents.scnassets/Cell.scn")!
    
    var body: some View
    {
        ZStack
        {
            ObjectSceneView(scene: viewed_scene)
            { scene_view in
                app_state.kinematic_preview_robot.update_model()
            }
            .onAppear
            {
                let clear_node = viewed_scene.rootNode.childNode(withName: "robot", recursively: true)
                clear_node?.removeFromParentNode()
                
                app_state.prepare_robot(group, scene: viewed_scene)
            }
            .background
            {
                Rectangle()
                    .fill(.gray)
            }
            #if !os(macOS)
            .ignoresSafeArea(.container, edges: .bottom)
            #endif
        }
        .overlay(alignment: .bottom)
        {
            PositionControl(location: $app_state.kinematic_preview_robot.pointer_location, rotation: $app_state.kinematic_preview_robot.pointer_rotation, scale: $app_state.kinematic_preview_robot.space_scale)
                .frame(width: 256)
                .background(.bar)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(radius: 8)
                .padding(.bottom)
        }
        .toolbar
        {
            Button (action: { show_inspector.toggle() })
            {
                Image(systemName: "sidebar.trailing")
            }
        }
        .inspector(isPresented: $show_inspector)
        {
            KinematicInspectorView(elements: $group.data)
        }
        .frame(minWidth: 640, minHeight: 480)
    }
}

struct KinematicInspectorView: View
{
    @Binding var elements: [KinematicElement]
    
    @State private var expanded = [false, false, false]
    
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            List
            {
                Section("Parameters")
                {
                    ForEach(elements.indices, id: \.self)
                    { index in
                        HStack(spacing: 12)
                        {
                            Text(elements[index].name)
                            TextField("0", value: $elements[index].value, formatter: NumberFormatter())
                            #if os(macOS)
                                .textFieldStyle(.squareBorder)
                            #endif
                            Stepper("", value: $elements[index].value)
                                .labelsHidden()
                        }
                    }
                }
            }
            #if os(macOS)
            .listStyle(.plain)
            #endif
            .modifier(ViewBorderer())
            .padding(.bottom)
            
            List
            {
                Section("Origin")
                {
                    DisclosureGroup("Location", isExpanded: $expanded[0])
                    {
                        OriginMoveView(origin_view_pos_location: $app_state.kinematic_preview_robot.origin_location)
                    }
                    
                    DisclosureGroup("Rotation", isExpanded: $expanded[1])
                    {
                        OriginRotateView(origin_view_pos_rotation: $app_state.kinematic_preview_robot.origin_rotation)
                    }
                    
                    DisclosureGroup("Scale", isExpanded: $expanded[2])
                    {
                        SpaceScaleView(space_scale: $app_state.kinematic_preview_robot.space_scale)
                    }
                    .onChange(of: app_state.kinematic_preview_robot.space_scale)
                    { _, _ in
                        app_state.kinematic_preview_robot.update_space_scale()
                    }
                }
            }
            .frame(height: 192)
            #if os(macOS)
            .listStyle(.plain)
            #endif
            .modifier(ViewBorderer())
        }
        .padding()
        .onAppear
        {
            app_state.update_robot_kinematic(elements)
        }
        .onChange(of: elements)
        { _, new_value in
            app_state.update_robot_kinematic(new_value)
            document_handler.document_update_kinematics()
        }
    }
}

//MARK: Scale elements
struct SpaceScaleView: View
{
    @Binding var space_scale: [Float]
    
    var body: some View
    {
        HStack(spacing: 8)
        {
            Text("X")
                .frame(width: 20)
            TextField("0", value: $space_scale[0], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $space_scale[0], in: 2...1000)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Y")
                .frame(width: 20)
            TextField("0", value: $space_scale[1], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $space_scale[1], in: 2...1000)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Z")
                .frame(width: 20)
            TextField("0", value: $space_scale[2], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $space_scale[2], in: 2...1000)
                .labelsHidden()
        }
    }
}

//MARK: Move elements
struct OriginMoveView: View
{
    @Binding var origin_view_pos_location: [Float]
    
    var body: some View
    {
        HStack(spacing: 8)
        {
            Text("X")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_location[0], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_location[0], in: -1000...1000)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Y")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_location[1], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_location[1], in: -1000...1000)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Z")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_location[2], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_location[2], in: -1000...1000)
                .labelsHidden()
        }
    }
}

//MARK: Rotate elements
struct OriginRotateView: View
{
    @Binding var origin_view_pos_rotation: [Float]
    
    var body: some View
    {
        HStack(spacing: 8)
        {
            Text("R")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_rotation[0], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_rotation[0], in: -180...180)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("P")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_rotation[1], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_rotation[1], in: -180...180)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("W")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_rotation[2], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_rotation[2], in: -180...180)
                .labelsHidden()
        }
    }
}

//MARK: - View element propeties
#if os(macOS)
let placement_trailing: ToolbarItemPlacement = .automatic
let quaternary_label_color: Color = Color(NSColor.quaternaryLabelColor)
#else
let placement_trailing: ToolbarItemPlacement = .navigationBarTrailing
let quaternary_label_color: Color = Color(UIColor.quaternaryLabel)
#endif

#Preview
{
    KinematicEditorView(group: .constant(KinematicGroup()))
        .frame(minWidth: 256, minHeight: 512)
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
