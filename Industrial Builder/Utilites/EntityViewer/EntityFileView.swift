//
//  SceneFileView.swift
//  Industrial Builder
//
//  Created by Artem on 14.10.2023.
//

import SwiftUI
import RealityKit

struct EntityFileView: View
{
    let entity: Entity?
    
    #if os(macOS) || os(iOS)
    @State private var camera_entity = Entity()
    @Binding var is_pan: Bool
    @State private var initial_camera_position: SIMD3<Float> = .zero
    #else
    private var center_entity = true
    
    @State private var model_size: SIMD3<Float> = .zero
    @State private var view_size: CGSize = .zero
    @State private var scale: Float = 1
    
    @State private var first_lodaded = false
    
    private let factor: Float = 0.5
    private let depth_shift: Float = 100 //200
    private let grid_factor: Float = 0.675
    
    @State private var offset: SIMD3<Float> = .zero
    
    public init(entity: Entity?)
    {
        self.entity = entity?.clone(recursive: true)
    }
    #endif
    
    var body: some View
    {
        if let entity = entity
        {
            GeometryReader
            { geometry in
                RealityView
                { content in
                    #if os(macOS) || os(iOS)
                    content.add(entity.clone(recursive: true))
                    content.add(camera_entity)
                    
                    let camera = PerspectiveCamera()
                    let bounds = entity.visualBounds(relativeTo: entity)
                    
                    let fov_y = camera.camera.fieldOfViewInDegrees * .pi / 180
                    let aspect = Float(geometry.size.width / geometry.size.height)
                    let fov_x = 2 * atan(tan(fov_y / 2) * aspect)
                    
                    let dx = bounds.extents.x / (2 * tan(fov_x / 2))
                    let dy = bounds.extents.y / (2 * tan(fov_y / 2))
                    let dz = bounds.extents.z / 2 + bounds.center.z
                    
                    let distance = max(dx, dy, dz)
                    
                    initial_camera_position = [bounds.center.x, bounds.center.y, distance + Float(0.25)]
                    camera_entity.addChild(camera)
                    content.add(camera_entity)
                    #else
                    let previewed_entity = entity
                    
                    let bounds = previewed_entity.visualBounds(relativeTo: previewed_entity)
                    model_size = bounds.extents
                    
                    content.add(previewed_entity)
                    #endif
                }
                #if os(macOS) || os(iOS)
                .realityViewCameraControls(is_pan ? .pan : .orbit)
                #elseif os(visionOS)
                .frame(depth: first_lodaded ? 0 : CGFloat(scale * model_size.x * 1000 + depth_shift * scale))
                .opacity(first_lodaded ? 0 : 1)
                .onChange(of: geometry.size)
                { _, new_size in
                    view_size = new_size
                    update_scale()
                }
                #endif
                .task
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)
                    {
                        #if os(macOS) || os(iOS)
                        camera_entity.position = initial_camera_position
                        #else
                        view_size = geometry.size
                        update_scale()
                        first_lodaded = false
                        #endif
                    }
                }
            }
            #if os(iOS)
            .background(.white)
            /*#elseif os(visionOS)
            .background
            {
                InfiniteGridView(
                    scale: CGFloat(scale * grid_factor),
                    offset: CGSize(
                        width: Double(offset.x * (1.35) * -1000),
                        height: Double(offset.y * (1.35) * -1000)
                    )
                )
            }*/
            #endif
        }
    }
    
    #if os(visionOS)
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
        
        previewed_entity.position = offset
    }
    #endif
}

#Preview
{
    #if !os(visionOS)
    EntityFileView(
        entity: ModelEntity(
            mesh: .generateBox(width: 0.1, height: 2, depth: 0.1),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]),
        is_pan: .constant(false)
    )
    #else
    EntityFileView(
        entity: ModelEntity(
            mesh: .generateBox(width: 0.1, height: 2, depth: 0.1),
            materials: [SimpleMaterial(color: .white, isMetallic: false)])
    )
    #endif
}
