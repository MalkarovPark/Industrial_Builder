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
    }
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
