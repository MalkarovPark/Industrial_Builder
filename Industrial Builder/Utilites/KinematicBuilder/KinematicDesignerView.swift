//
//  KinematicDesignerView.swift
//  Industrial Builder
//
//  Created by Artem on 23.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct KinematicDesignerView: View
{
    @Binding var group: KinematicGroup
    @EnvironmentObject var app_state: AppState
    
    @State private var pointer_location: [Float] = [0, 0, 0]
    @State private var pointer_rotation: [Float] = [0, 0, 0]
    
    @State private var show_inspector = true
    
    @State private var origin_move_view_presented = false
    @State private var origin_rotate_view_presented = false
    @State private var space_scale_view_presented = false
    @State private var make_components_view_presented = false
    
    private let viewed_scene = SCNScene(named: "KinematicComponents.scnassets/Cell.scn")!
    
    var body: some View
    {
        ZStack
        {
            ObjectSceneView(scene: viewed_scene)
            .onAppear
            {
                let cleaning_node = viewed_scene.rootNode.childNode(withName: "robot", recursively: true)
                cleaning_node?.removeFromParentNode()
                
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
        .overlay(alignment: .bottomLeading)
        {
            VStack(spacing: 0)
            {
                Button(action: { origin_rotate_view_presented.toggle() })
                {
                    Image(systemName: "rotate.3d")
                        .imageScale(.large)
                        .padding()
                }
                .buttonStyle(.borderless)
                #if os(iOS)
                .foregroundColor(.black)
                #endif
                .popover(isPresented: $origin_rotate_view_presented)
                {
                    OriginRotateView(origin_rotate_view_presented: $origin_rotate_view_presented, origin_view_pos_rotation: $app_state.kinematic_preview_robot.origin_rotation)
                }
                .onDisappear
                {
                    origin_rotate_view_presented.toggle()
                }
                Divider()
                
                Button(action: { origin_move_view_presented.toggle() })
                {
                    Image(systemName: "move.3d")
                        .imageScale(.large)
                        .padding()
                }
                .buttonStyle(.borderless)
                #if os(iOS)
                .foregroundColor(.black)
                #endif
                .popover(isPresented: $origin_move_view_presented)
                {
                    OriginMoveView(origin_move_view_presented: $origin_move_view_presented, origin_view_pos_location: $app_state.kinematic_preview_robot.origin_location)
                }
                .onDisappear
                {
                    origin_move_view_presented.toggle()
                }
                Divider()
                
                Button(action: { space_scale_view_presented.toggle() })
                {
                    Image(systemName: "scale.3d")
                        .imageScale(.large)
                        .padding()
                }
                #if os(iOS)
                .foregroundColor(.black)
                #endif
                .popover(isPresented: $space_scale_view_presented)
                {
                    SpaceScaleView(space_scale_view_presented: $space_scale_view_presented, space_scale: $app_state.kinematic_preview_robot.space_scale)
                }
                .onChange(of: app_state.kinematic_preview_robot.space_scale)
                { _, _ in
                    app_state.kinematic_preview_robot.update_space_scale()
                }
                .onDisappear
                {
                    space_scale_view_presented.toggle()
                }
                .buttonStyle(.borderless)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(radius: 8)
            .fixedSize(horizontal: true, vertical: false)
            .padding()
        }
        .toolbar
        {
            Button (action: { make_components_view_presented.toggle() })
            {
                //Image(systemName: "hexagon")
                Label("Make Module", systemImage: "arrow.up.document")
            }
            .popover(isPresented: $make_components_view_presented, arrowEdge: .bottom)
            {
                MakeRobotComponentsView(group: $group)
            }
            
            Button (action: { show_inspector.toggle() })
            {
                //Image(systemName: "sidebar.trailing")
                Label("Kinematic Inspector", systemImage: "sidebar.trailing")
            }
        }
        .inspector(isPresented: $show_inspector)
        {
            KinematicInspectorView(elements: $group.data)
        }
        .frame(minWidth: 640, minHeight: 480)
    }
}

//MARK: Scale elements
struct SpaceScaleView: View
{
    @Binding var space_scale_view_presented: Bool
    @Binding var space_scale: [Float]
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            Text("Space Scale")
                .font(.title3)
                .padding([.horizontal, .top])
            
            HStack(spacing: 8)
            {
                Text("X:")
                    .frame(width: 20)
                TextField("0", value: $space_scale[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $space_scale[0], in: 2...1000)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("Y:")
                    .frame(width: 20)
                TextField("0", value: $space_scale[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $space_scale[1], in: 2...1000)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("Z:")
                    .frame(width: 20)
                TextField("0", value: $space_scale[2], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $space_scale[2], in: 2...1000)
                    .labelsHidden()
            }
        }
        .padding([.bottom, .leading, .trailing])
        #if os(macOS)
        .frame(minWidth: 128, idealWidth: 192, maxWidth: 256)
        #else
        .frame(minWidth: 192, idealWidth: 256, maxWidth: 288)
        #endif
    }
}

//MARK: Move elements
struct OriginMoveView: View
{
    @Binding var origin_move_view_presented: Bool
    @Binding var origin_view_pos_location: [Float]
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            Text("Origin Location")
                .font(.title3)
                .padding([.horizontal, .top])
            
            HStack(spacing: 8)
            {
                Text("X:")
                    .frame(width: 20)
                TextField("0", value: $origin_view_pos_location[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_location[0], in: -20000...20000)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("Y:")
                    .frame(width: 20)
                TextField("0", value: $origin_view_pos_location[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_location[1], in: -20000...20000)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("Z:")
                    .frame(width: 20)
                TextField("0", value: $origin_view_pos_location[2], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_location[2], in: -20000...20000)
                    .labelsHidden()
            }
        }
        .padding([.bottom, .leading, .trailing])
        #if os(macOS)
        .frame(minWidth: 128, idealWidth: 192, maxWidth: 256)
        #else
        .frame(minWidth: 192, idealWidth: 256, maxWidth: 288)
        #endif
    }
}

//MARK: Rotate elements
struct OriginRotateView: View
{
    @Binding var origin_rotate_view_presented: Bool
    @Binding var origin_view_pos_rotation: [Float]
    
    var body: some View
    {
        VStack(spacing: 12)
        {
            Text("Origin Rotation")
                .font(.title3)
                .padding([.horizontal, .top])
            
            HStack(spacing: 8)
            {
                Text("R:")
                    .frame(width: label_width)
                TextField("0", value: $origin_view_pos_rotation[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_rotation[0], in: -180...180)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("P:")
                    .frame(width: label_width)
                TextField("0", value: $origin_view_pos_rotation[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_rotation[1], in: -180...180)
                    .labelsHidden()
            }
            
            HStack(spacing: 8)
            {
                Text("W:")
                    .frame(width: label_width)
                TextField("0", value: $origin_view_pos_rotation[2], format: .number)
                    .textFieldStyle(.roundedBorder)
                #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                #endif
                Stepper("Enter", value: $origin_view_pos_rotation[2], in: -180...180)
                    .labelsHidden()
            }
        }
        .padding([.bottom, .leading, .trailing])
        #if os(macOS)
        .frame(minWidth: 128, idealWidth: 192, maxWidth: 256)
        #elseif os(iOS)
        .frame(minWidth: 192, idealWidth: 256, maxWidth: 288)
        #else
        .frame(minWidth: 256, idealWidth: 288, maxWidth: 320)
        #endif
    }
}

#if !os(visionOS)
let label_width = 20.0
#else
let label_width = 26.0
#endif



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
    KinematicDesignerView(group: .constant(KinematicGroup()))
        .frame(minWidth: 256, minHeight: 512)
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
