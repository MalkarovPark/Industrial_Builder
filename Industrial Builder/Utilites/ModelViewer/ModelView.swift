//
//  ModelView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 14.10.2023.
//

import SwiftUI
import SceneKit

struct ModelView: View
{
    @Binding var node: SCNNode
    
    var body: some View
    {
        ElementSceneView(node: node)
    }
}

//MARK: - Scene views
struct ElementSceneView: UIViewRepresentable
{
    let scene_view = SCNView(frame: .zero)
    let viewed_scene = SCNScene()
    let node: SCNNode
    
    func scn_scene(context: Context) -> SCNView
    {
        scene_view.scene = viewed_scene
        scene_view.delegate = context.coordinator
        scene_view.scene?.background.contents = UIColor.clear
        
        scene_view.scene?.rootNode.addChildNode(node.clone())
        
        return scene_view
    }
    
    #if os(macOS)
    func makeNSView(context: Context) -> SCNView
    {
        //Add gesture recognizer
        scene_view.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:))))
        
        //Add reset double tap recognizer for macOS
        let double_tap_gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_reset_double_tap(_:)))
        double_tap_gesture.numberOfClicksRequired = 2
        scene_view.addGestureRecognizer(double_tap_gesture)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        scene_view.backgroundColor = UIColor.clear
        
        let camera_node = SCNNode()
        camera_node.camera = SCNCamera()
        camera_node.position = SCNVector3(0, 0, 2)
        viewed_scene.rootNode.addChildNode(camera_node)
        scene_view.pointOfView = camera_node
        
        return scn_scene(context: context)
    }
    #else
    func makeUIView(context: Context) -> SCNView
    {
        //Add gesture recognizer
        scene_view.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:))))
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        scene_view.backgroundColor = UIColor.clear
        
        app_state.reset_view = false
        app_state.reset_view_enabled = true
        
        return scn_scene(context: context)
    }
    #endif
    
    #if os(macOS)
    func updateNSView(_ ui_view: SCNView, context: Context)
    {
        
    }
    #else
    func updateUIView(_ ui_view: SCNView, context: Context)
    {
        
    }
    #endif
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(self, scene_view)
    }
    
    final class Coordinator: NSObject, SCNSceneRendererDelegate
    {
        var control: ElementSceneView
        
        init(_ control: ElementSceneView, _ scn_view: SCNView)
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
        
        #if os(macOS)
        private var on_reset_view = false
        #endif
        
        @objc func handle_tap(_ gesture_recognize: UITapGestureRecognizer)
        {
            let tap_location = gesture_recognize.location(in: scn_view)
            let hit_results = scn_view.hitTest(tap_location, options: [:])
            var result = SCNHitTestResult()
            
            if hit_results.count > 0
            {
                result = hit_results[0]
                
                print(result.localCoordinates)
                print("🍮 tapped – \(result.node.name ?? "None")")
            }
        }
        
        @objc func handle_reset_double_tap(_ gesture_recognize: UITapGestureRecognizer)
        {
            reset_camera_view_position(locataion: SCNVector3(0, 0, 2), rotation: SCNVector4Zero, view: scn_view)
            
            func reset_camera_view_position(locataion: SCNVector3, rotation: SCNVector4, view: SCNView)
            {
                if !on_reset_view
                {
                    on_reset_view = true
                    
                    let reset_action = SCNAction.group([SCNAction.move(to: locataion, duration: 0.5), SCNAction.rotate(toAxisAngle: rotation, duration: 0.5)])
                    view.defaultCameraController.pointOfView?.runAction(
                        reset_action, completionHandler: { self.on_reset_view = false })
                }
            }
        }
    }
    
    func scene_check() //Render functions
    {
        
    }
}

//MARK: - Scene Views typealilases
#if os(macOS)
typealias UIViewRepresentable = NSViewRepresentable
typealias UITapGestureRecognizer = NSClickGestureRecognizer
typealias UIColor = NSColor
#endif

#Preview
{
    ModelView(node: .constant(SCNNode()))
}
