//
//  KinematicEditorView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 23.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct KinematicEditorView: View
{
    @Binding var is_presented: Bool
    @Binding var kinematic: KinematicGroup
    
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
            on_tap:
            { _, _ in
                //Tap gesture handler
            }
            .onAppear
            {
                app_state.prepare_robot(kinematic, scene: viewed_scene)
            }
            .background
            {
                Rectangle()
                    .fill(.gray)
            }
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
        .overlay(alignment: .topTrailing)
        {
            Button (action: { show_inspector.toggle() })
            {
                Image(systemName: "sidebar.trailing")
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .inspector(isPresented: $show_inspector)
        {
            KinematicInspectorView(elements: $kinematic.data)
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        .frame(minWidth: 640, minHeight: 480)
    }
}

struct KinematicInspectorView: View
{
    @Binding var elements: [KinematicElement]
    
    @State private var expanded = [true, false, false, false]
    
    @EnvironmentObject var app_state: AppState
    
    var body: some View
    {
        List
        {
            DisclosureGroup("Parameters", isExpanded: $expanded[0])
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
            
            Section("Origin")
            {
                DisclosureGroup("Location", isExpanded: $expanded[1])
                {
                    OriginMoveView(origin_view_pos_location: $app_state.kinematic_preview_robot.origin_location)
                }
                
                DisclosureGroup("Rotation", isExpanded: $expanded[2])
                {
                    OriginRotateView(origin_view_pos_rotation: $app_state.kinematic_preview_robot.origin_rotation)
                }
                
                DisclosureGroup("Scale", isExpanded: $expanded[3])
                {
                    SpaceScaleView(space_scale: $app_state.kinematic_preview_robot.space_scale)
                }
                .onChange(of: app_state.kinematic_preview_robot.space_scale)
                { _, _ in
                    app_state.kinematic_preview_robot.update_space_scale()
                }
            }
        }
        #if os(macOS)
        .listStyle(.plain)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        #if os(macOS)
        .padding()
        #endif
        .onAppear
        {
            app_state.update_robot_kinematic(elements)
        }
        .onChange(of: elements)
        { _, new_value in
            app_state.update_robot_kinematic(new_value)
            app_state.document_notify.toggle()
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
            Stepper("Enter", value: $origin_view_pos_location[0], in: -50...50)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Y")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_location[1], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_location[1], in: -50...50)
                .labelsHidden()
        }
        
        HStack(spacing: 8)
        {
            Text("Z")
                .frame(width: 20)
            TextField("0", value: $origin_view_pos_location[2], format: .number)
                .textFieldStyle(.roundedBorder)
            Stepper("Enter", value: $origin_view_pos_location[2], in: -50...50)
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
    KinematicEditorView(is_presented: .constant(true), kinematic: .constant(KinematicGroup(name: "", type: .portal, data: [KinematicElement]())))
        .frame(minWidth: 256, minHeight: 512)
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
