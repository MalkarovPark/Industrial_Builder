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
    let grid_factor: Float = 0.675
    
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
        .background
        {
            InfiniteGridView(scale: CGFloat(scale * grid_factor))
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

#Preview(windowStyle: .automatic)
{
    @Previewable @State var grid_factor: Float = 0.675
    #if os(visionOS)
    PartModelView(entity: ModelEntity(
        mesh: .generateBox(size: Float(0.1)/*, cornerRadius: Float(0.01)*/),
        materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
    )) // 100mm^3
    #else
    /*ZStack
    {
        Rectangle()
            .fill(.white)

        InfiniteGridView(scale: grid_factor)
        
        Slider(value: $scale)
    }
    .frame(width: 256, height: 256)
    .border(.teal)
    .padding(40)*/
    
    PartModelView(entity: ModelEntity(
        mesh: .generateBox(size: Float(0.2)/*, cornerRadius: Float(0.01)*/),
        materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
    ), is_pan: .constant(false))
    #endif
}

struct InfiniteGridView: View
{
    var cell_size: CGFloat = 20
    var major_step: Int = 10
    
    /// Global grid scale.
    var scale: CGFloat = 1.0
    
    var minor_color = Color.gray.opacity(0.25)
    var major_color = Color.gray.opacity(0.40)
    var axis_color  = Color.gray.opacity(0.60)
    
    var offset: CGSize = .zero
    
    var body: some View
    {
        GeometryReader
        { geometry in
            Canvas
            { context, size in
                
                let scaled_cell_size = cell_size * scale
                
                guard scaled_cell_size > 1 else { return }
                
                let center_x = size.width  * 0.5 + offset.width
                let center_y = size.height * 0.5 + offset.height
                
                let columns = Int(ceil(size.width / scaled_cell_size)) + 2
                let rows    = Int(ceil(size.height / scaled_cell_size)) + 2
                
                
                for i in -columns...columns
                {
                    let x = center_x + CGFloat(i) * scaled_cell_size
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    
                    let color: Color
                    let width: CGFloat
                    
                    if i == 0
                    {
                        color = axis_color
                        width = 2
                    }
                    else if i % major_step == 0
                    {
                        color = major_color
                        width = 1.5
                    }
                    else
                    {
                        color = minor_color
                        width = 1
                    }
                    
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: width
                    )
                }
                
                
                for i in -rows...rows
                {
                    let y = center_y + CGFloat(i) * scaled_cell_size
                    
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    
                    let color: Color
                    let width: CGFloat
                    
                    if i == 0
                    {
                        color = axis_color
                        width = 2
                    }
                    else if i % major_step == 0
                    {
                        color = major_color
                        width = 1.5
                    }
                    else
                    {
                        color = minor_color
                        width = 1
                    }
                    
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: width
                    )
                }
            }
            //.ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}
