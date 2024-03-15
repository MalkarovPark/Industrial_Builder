//
//  ModelView.swift
//  Industrial Builder
//
//  Created by Artem on 14.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct ModelView: View
{
    @Binding var node: SCNNode
    
    var body: some View
    {
        //SceneView(scene: SCNScene(named: "KinematicComponents.scnassets/Robots/6DOF.scn"))
        ObjectSceneView(node: node, on_render: { _ in }, on_tap: tapper(gesture_recognizer:scn_view:))
        //ElementSceneView(scene: SCNScene(named: "KinematicComponents.scnassets/Robots/6DOF.scn")!)
    }
    
    func tapper(gesture_recognizer: UITapGestureRecognizer, scn_view: SCNView)
    {
        let tap_location = gesture_recognizer.location(in: scn_view)
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
