//
//  ModelView.swift
//  Industrial Builder
//
//  Created by Artem on 14.10.2023.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct SceneView: View
{
    @Binding var node: SCNNode
    
    var body: some View
    {
        ObjectSceneView(node: node)
        // ObjectSceneView(node: node, on_tap: tapper(gesture_recognizer:scn_view:))
    }
    
    /*func tapper(gesture_recognizer: UITapGestureRecognizer, scn_view: SCNView)
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
    }*/
}

// MARK: - Scene Views typealilases
#if os(macOS)
typealias UIViewRepresentable = NSViewRepresentable
typealias UITapGestureRecognizer = NSClickGestureRecognizer
typealias UIColor = NSColor
#endif

#Preview
{
    SceneView(node: .constant(SCNNode()))
}
