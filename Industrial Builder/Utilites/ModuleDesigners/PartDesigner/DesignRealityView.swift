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
    
    @State private var preview_entity: Entity?
    @State private var model_size: SIMD3<Float> = .zero
    @State private var view_size: CGSize = .zero
    @State private var scale: Float = 1
    
    private let factor: Float = 0.5
    private let shift: Float = 200
    private let grid_factor: Float = 0.675
    
    public var body: some View
    {
        GeometryReader
        { geometry in
            RealityView
            { content in
                if let preview_entity = entity
                {
                    let bounds = preview_entity.visualBounds(relativeTo: nil)
                    model_size = bounds.extents
                    
                    content.add(preview_entity)
                }
            }
            .frame(depth: CGFloat(scale * model_size.x * 1000 + shift))
            .onChange(of: geometry.size)
            { _, new_size in
                view_size = new_size
                update_scale()
            }
        }
        .background
        {
            InfiniteGridView(scale: CGFloat(scale * grid_factor))
        }
    }
    
    private func update_scale()
    {
        guard let preview_entity = entity else { return }
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
            //.ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

#Preview(windowStyle: .automatic)
{
    PartModelView(entity: ModelEntity(
        mesh: .generateBox(size: Float(0.1)/*, cornerRadius: Float(0.01)*/),
        materials: [SimpleMaterial(color: .cyan, isMetallic: true)]
    )) // 100mm^3
}

#Preview
{
    @Previewable @State var scale: CGFloat = 1.0
    
    VStack(spacing: 32)
    {
        ZStack
        {
            Rectangle()
                .fill(.white)

            InfiniteGridView(scale: scale)
        }
        .frame(width: 256, height: 256)
        
        Slider(value: $scale, in: 0 ... 2)
            .frame(width: 256)
    }
}
