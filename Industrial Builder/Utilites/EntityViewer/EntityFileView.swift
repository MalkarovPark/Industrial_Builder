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
    @State private var previewed_entity: Entity?
    @State private var camera_entity = Entity()
    @Binding var is_pan: Bool
    @State private var initial_camera_position: SIMD3<Float> = .zero
    #endif

    var body: some View
    {
        #if os(macOS) || os(iOS)
        if let entity = entity
        {
            GeometryReader
            { geometry in
                RealityView
                { content in
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
                    
                    //camera.position = [bounds.center.x, bounds.center.y, distance + Float(0.25)]
                    initial_camera_position = [bounds.center.x, bounds.center.y, distance + Float(0.25)]
                    camera_entity.addChild(camera)
                    content.add(camera_entity)
                    //content.add(camera)
                }
                .realityViewCameraControls(is_pan ? .pan : .orbit)
                .task
                {
                    //camera_entity.position = initial_camera_position
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)
                    {
                        camera_entity.position = initial_camera_position
                    }
                }
                /*.onChange(of: is_pan)
                { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)
                    {
                        camera_entity.position = initial_camera_position
                    }
                }*/
            }
            #if os(iOS)
            .background(.white)
            #endif
        }
        #else
        DesignRealityView(entity: entity)
        #endif
    }
}

#Preview
{
    EntityFileView(
        entity: ModelEntity(
            mesh: .generateBox(width: 0.1, height: 2, depth: 0.1),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]),
        is_pan: .constant(false)
    )
}
