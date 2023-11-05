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
    @EnvironmentObject var app_state: AppState
    
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
        let tap_gesture_recognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
        scene_view.allowsCameraControl = true
        scene_view.rendersContinuously = true
        scene_view.autoenablesDefaultLighting = true
        
        scene_view.backgroundColor = UIColor.clear
        
        app_state.reset_view = false
        app_state.reset_view_enabled = true
        
        return scn_scene(context: context)
    }
    #else
    func makeUIView(context: Context) -> SCNView
    {
        //Add gesture recognizer
        let tap_gesture_recognizer = UIGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
        scene_view.addGestureRecognizer(tap_gesture_recognizer)
        
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
        app_state.reset_camera_view_position(locataion: SCNVector3(0, 0, 0), rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0), view: ui_view)
    }
    #else
    func updateUIView(_ ui_view: SCNView, context: Context)
    {
        app_state.reset_camera_view_position(locataion: SCNVector3(0, 0, 0), rotation: SCNVector4(x: 0, y: 0, z: 0, w: 0), view: ui_view)
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
    }
    
    func scene_check() //Render functions
    {
        /*if app_state.preview_update_scene
        {
            let remove_node = scene_view.scene?.rootNode.childNode(withName: "Figure", recursively: true)
            remove_node?.removeFromParentNode()
            
            scene_view.scene?.rootNode.addChildNode(app_state.previewed_object?.node ?? SCNNode())
            app_state.previewed_object?.node?.name = "Figure"
            app_state.preview_update_scene = false
        }*/
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
