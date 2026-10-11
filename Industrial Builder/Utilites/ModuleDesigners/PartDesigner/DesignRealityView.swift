//
//  DesignRealityView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 15.07.2026.
//

import SwiftUI
import RealityKit

public struct DesignRealityView: View
{
    let entity: Entity?
    
    //@State private var previewed_entity: Entity?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var view_size: CGSize = .zero
    @State private var scale: Float = 1
    
    private let factor: Float = 0.5
    private let shift: Float = 200
    private let grid_factor: Float = 0.675
    
    @State private var offset: SIMD3<Float> = .zero
    
    public var body: some View
    {
        GeometryReader
        { geometry in
            RealityView
            { content in
                if let previewed_entity = entity
                {
                    let bounds = previewed_entity.visualBounds(relativeTo: nil)
                    model_size = bounds.extents
                    
                    content.add(previewed_entity)
                }
            }
            .frame(depth: CGFloat(scale * model_size.x * 1000 + shift * scale))
            .onChange(of: geometry.size)
            { _, new_size in
                view_size = new_size
                update_scale()
            }
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
                {
                    view_size = geometry.size
                    update_scale()
                }
            }
        }
        .background
        {
            InfiniteGridView(
                scale: CGFloat(scale * grid_factor),
                offset: CGSize(
                    width: Double(offset.x * (1.35) * -1000),
                    height: Double(offset.y * (1.35) * -1000)
                )
            )
        }
    }
    
    private func update_scale()
    {
        // Scale Entity
        guard let previewed_entity = entity else { return }
        guard model_size != .zero else { return }
        
        let view_width = Float(view_size.width) * 0.001
        let view_height = Float(view_size.height) * 0.001
        
        let min_view_dimension = min(view_width, view_height)
        
        let model_radius = length(model_size) * 0.5
        
        guard model_radius > 0, min_view_dimension > 0
        else { return }
        
        scale = (min_view_dimension / length(model_size)) * factor
        
        previewed_entity.scale = SIMD3<Float>(repeating: scale)
        
        // Center Entity
        let bounds = previewed_entity.visualBounds(relativeTo: previewed_entity)
        
        offset = -bounds.center * scale
        
        previewed_entity.position.x = offset.x
        previewed_entity.position.y = offset.y
    }
}

public struct InfiniteGridView: View
{
    var cell_size: CGFloat = 20
    var major_step: Int = 10
    
    var scale: CGFloat = 1.0 // Global grid scale
    
    var minor_color = Color.gray.opacity(0.25)
    var major_color = Color.gray.opacity(0.40)
    var axis_color  = Color.gray.opacity(0.60)
    
    var offset: CGSize = .zero
    
    public init(scale: CGFloat, offset: CGSize = .zero)
    {
        self.scale = scale
        self.offset = offset
    }
    
    public var body: some View
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
        }
        .allowsHitTesting(false)
    }
}

#Preview(windowStyle: .automatic)
{
    PartModelView(entity: ModelEntity(
        mesh: .generateBox(width: 0.1, height: 0.2, depth: 0.1)/*mesh: .generateBox(size: Float(0.1)/*, cornerRadius: Float(0.01)*/)*/,
        materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
    )) // 100mm^3
}
