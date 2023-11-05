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
    
    var body: some View
    {
        ZStack
        {
            KinematicSceneView(kinematic_type: kinematic.type)
        }
        .overlay(alignment: .bottom)
        {
            PositionControl(location: $app_state.kinematic_preview_robot.pointer_location, rotation: $app_state.kinematic_preview_robot.pointer_rotation, scale: $app_state.kinematic_preview_robot.space_scale)
                .frame(width: 256)
                .background(.bar)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(radius: 4)
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

struct KinematicSceneView: UIViewRepresentable
{
    @EnvironmentObject var app_state: AppState
    
    let scene_view = SCNView(frame: .zero)
    let viewed_scene = SCNScene(named: "KinematicComponents.scnassets/Cell.scn") ?? SCNScene()
    
    public let kinematic_type: KinematicGroupTypes
    
    func scn_scene(context: Context) -> SCNView
    {
        scene_view.scene = viewed_scene
        scene_view.delegate = context.coordinator
        //scene_view.scene?.background.contents = UIColor.clear
        return scene_view
    }
    
#if os(macOS)
    func makeNSView(context: Context) -> SCNView
    {
        app_state.prepare_robot(kinematic_type, scene: viewed_scene)
        
        //Add gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        app_state.reset_view = false
        app_state.reset_view_enabled = true
        
        return scn_scene(context: context)
    }
#else
    func makeUIView(context: Context) -> SCNView
    {
        app_state.prepare_robot(kinematic_type, scene: viewed_scene)
        
        //Add gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        app_state.reset_view = false
        app_state.reset_view_enabled = true
        
        return scn_scene(context: context)
    }
#endif
    
#if os(macOS)
    func updateNSView(_ ui_view: SCNView, context: Context)
    {
        app_state.reset_camera_view_position(locataion: app_state.kinematic_preview_robot.camera_node?.position ?? SCNVector3(0, 0, 0), rotation: app_state.kinematic_preview_robot.camera_node?.rotation ?? SCNVector4(x: 0, y: 0, z: 0, w: 0), view: ui_view)
    }
#else
    func updateUIView(_ ui_view: SCNView, context: Context)
    {
        app_state.reset_camera_view_position(locataion: app_state.kinematic_preview_robot.camera_node?.position ?? SCNVector3(0, 0, 0), rotation: app_state.kinematic_preview_robot.camera_node?.rotation ?? SCNVector4(x: 0, y: 0, z: 0, w: 0), view: ui_view)
    }
#endif
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self, scene_view)
    }
    
    final class Coordinator: NSObject, SCNSceneRendererDelegate
    {
        var control: KinematicSceneView
        
        init(_ control: KinematicSceneView, _ scn_view: SCNView)
        {
            self.control = control
            
            self.scn_view = scn_view
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
        {
            control.scene_check()
        }
        
        private let scn_view: SCNView
        @objc func handle_tap(_ gesture_recognize: UITapGestureRecognizer)
        {
            let tap_location = gesture_recognize.location(in: scn_view)
            let hit_results = scn_view.hitTest(tap_location, options: [:])
            var result = SCNHitTestResult()
            
            if hit_results.count > 0
            {
                
            }
        }
    }
    
    func scene_check() //Render functions
    {
        
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
