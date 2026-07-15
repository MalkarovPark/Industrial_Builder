//
//  PartModelView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct PartModelView: View
{
    let entity: Entity?
    
    @State private var preview_entity: Entity?
    
    @StateObject var workspace = Workspace()
    @StateObject var previewed_part = Part(name: "preview", entity: Entity())
    
    #if os(macOS) || os(iOS)
    @Binding var is_pan: Bool
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    
    var body: some View
    {
        ZStack
        {
            RealityView
            { content in
                scene_content = content
                scene_content?.camera = .virtual
                
                workspace.place_entity(in: content)
                workspace.add_part(previewed_part)
                
                place_entity(entity)
            }
            .realityViewCameraControls(is_pan ? .pan : .orbit)
            .gesture(
                TapGesture()
                    .onEnded
                    {
                        workspace.focus(on: previewed_part.model_entity)
                    }
            )
        }
        .ignoresSafeArea(.container, edges: .vertical)
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
    }
    #else
    @State private var scene_content: RealityViewContent?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var view_size: CGSize = .zero
    @State private var scale: Float = 1
    let factor: Float = 0.5
    let shift: Float = 200
    
    var body: some View
    {
        GeometryReader
        { geometry in
            RealityView
            { content in
                scene_content = content
                
                if preview_entity == nil
                {
                    preview_entity = (entity ?? Entity()).clone(recursive: true)
                    
                    if let preview_entity
                    {
                        let bounds = preview_entity.visualBounds(relativeTo: nil)
                        model_size = bounds.extents
                        
                        content.add(preview_entity)
                    }
                }
            }
            .onChange(of: geometry.size)
            { _, new_size in
                view_size = new_size
                update_scale()
            }
            .frame(depth: CGFloat(scale * model_size.x * 1000 + shift))
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
    }
    
    private func update_scale()
    {
        guard let preview_entity else { return }
        guard model_size != .zero else { return }

        let viewWidth = Float(view_size.width) * 0.001
        let viewHeight = Float(view_size.height) * 0.001

        let minViewDimension = min(viewWidth, viewHeight)

        let modelRadius = length(model_size) * 0.5

        guard modelRadius > 0,
              minViewDimension > 0
        else { return }

        scale = (minViewDimension / length(model_size)) * factor

        preview_entity.scale = SIMD3<Float>(repeating: scale)
    }
    #endif
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            preview_entity = new_entity
            previewed_part.model_entity?.addChild(new_entity)
        }
        
        #if os(macOS) || os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: previewed_part.model_entity)
        }
        #endif
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        
        place_entity(new_entity)
    }
}
