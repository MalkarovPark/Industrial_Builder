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
    var body: some View
    {
        ElementSceneView()
            //.frame(height: 240)
    }
}

//MARK: - Scene views
struct ElementSceneView: UIViewRepresentable
{
    //@AppStorage("WorkspaceImagesStore") private var workspace_images_store: Bool = true
    
    //@EnvironmentObject var base_workspace: Workspace
    //@EnvironmentObject var app_state: AppState
    
    let scene_view = SCNView(frame: .zero)
    let viewed_scene = SCNScene() //SCNScene(named: "Components.scnassets/View.scn")!
    
    func scn_scene(context: Context) -> SCNView
    {
        //app_state.reset_view = false
        //app_state.reset_view_enabled = true
        scene_view.scene = viewed_scene
        scene_view.delegate = context.coordinator
        scene_view.scene?.background.contents = UIColor.clear
        return scene_view
    }
    
    #if os(macOS)
    func makeNSView(context: Context) -> SCNView
    {
        //base_workspace.camera_node = viewed_scene.rootNode.childNode(withName: "camera", recursively: true)
        
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
        //base_workspace.camera_node = viewed_scene.rootNode.childNode(withName: "camera", recursively: true)
        
        //Add gesture recognizer
        let tap_gesture_recognizer = UIGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handle_tap(_:)))
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
        //Update commands
        /*app_state.reset_camera_view_position(workspace: base_workspace, view: ui_view)
        
        if app_state.get_scene_image && workspace_images_store
        {
            app_state.get_scene_image = false
            app_state.previewed_object?.image = ui_view.snapshot()
        }*/
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
        //Update commands
        /*app_state.reset_camera_view_position(workspace: base_workspace, view: ui_view)
        
        if app_state.get_scene_image && workspace_images_store
        {
            app_state.get_scene_image = false
            app_state.previewed_object?.image = ui_view.snapshot()
        }*/
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
    ModelView()
}
