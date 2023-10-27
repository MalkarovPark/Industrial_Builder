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
    
    @State private var pointer_location: [Float] = [0, 0, 0]
    @State private var pointer_rotation: [Float] = [0, 0, 0]
    @State private var space_scale: [Float] = [100, 100, 100]
    @State private var show_inspector = true
    
    var body: some View
    {
        ZStack
        {
            KinematicSceneView()
        }
        .overlay(alignment: .bottom)
        {
            PositionControl(location: $pointer_location, rotation: $pointer_rotation, scale: $space_scale)
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
            KinematicInspectorView()
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        .frame(minWidth: 640, minHeight: 480)
    }
}

struct KinematicSceneView: UIViewRepresentable
{
    let scene_view = SCNView(frame: .zero)
    let viewed_scene = SCNScene() //SCNScene(named: "Scene file name") ?? SCNScene()
    
    func scn_scene(context: Context) -> SCNView
    {
        scene_view.scene = viewed_scene
        scene_view.delegate = context.coordinator
        scene_view.scene?.background.contents = UIColor.clear
        return scene_view
    }
    
#if os(macOS)
    func makeNSView(context: Context) -> SCNView
    {
        //Add gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        scene_view.backgroundColor = UIColor.clear
        
        return scn_scene(context: context)
    }
#else
    func makeUIView(context: Context) -> SCNView
    {
        let greenMaterial = SCNMaterial()
                greenMaterial.diffuse.contents = UIColor.green
        let greenBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
                greenBox.materials = [greenMaterial]
        let boxNode = SCNNode(geometry: greenBox)
        scene_view.scene?.rootNode.addChildNode(boxNode)
        
        //Add gesture recognizer
        let tap_gesture_recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        scene_view.backgroundColor = UIColor.clear
        
        return scn_scene(context: context)
    }
#endif
    
#if os(macOS)
    func updateNSView(_ ui_view: SCNView, context: Context)
    {
        let greenMaterial = SCNMaterial()
                greenMaterial.diffuse.contents = UIColor.green
        let greenBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
                greenBox.materials = [greenMaterial]
        let boxNode = SCNNode(geometry: greenBox)
        scene_view.scene?.rootNode.addChildNode(boxNode)
    }
#else
    func updateUIView(_ ui_view: SCNView, context: Context)
    {
        let greenMaterial = SCNMaterial()
                greenMaterial.diffuse.contents = UIColor.green
        let greenBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
                greenBox.materials = [greenMaterial]
        let boxNode = SCNNode(geometry: greenBox)
        scene_view.scene?.rootNode.addChildNode(boxNode)
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

struct PositionParameterView: View
{
    @Binding var position_parameter_view_presented: Bool
    @Binding var parameter_value: Float
    @Binding var limit_min: Float
    @Binding var limit_max: Float
    
    var body: some View
    {
        HStack(spacing: 8)
        {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    parameter_value = 0
                }
                //parameter_value = 0
                position_parameter_view_presented.toggle()
            })
            {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.borderedProminent)
            #if os(macOS)
            .foregroundColor(Color.white)
            #else
            .padding(.leading, 8)
            #endif
            
            TextField("0", value: $parameter_value, format: .number)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
                .frame(width: 64)
            #else
                .frame(width: 128)
            #endif
            
            Stepper("Enter", value: $parameter_value, in: Float(limit_min)...Float(limit_max))
                .labelsHidden()
            #if os(iOS) || os(visionOS)
                .padding(.trailing, 8)
            #endif
        }
        .padding(8)
    }
}

struct KinematicInspectorView: View
{
    var body: some View
    {
        List
        {
            Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Model")) {
                /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
            }
            
            Section("Parameters")
            {
                
            }
        }
        #if os(macOS)
        .listStyle(.plain)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        #if os(macOS)
        .padding()
        #endif
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
    KinematicEditorView(is_presented: .constant(true))
        .frame(minWidth: 256, minHeight: 512)
        .environmentObject(StandardTemplateConstruct())
}
