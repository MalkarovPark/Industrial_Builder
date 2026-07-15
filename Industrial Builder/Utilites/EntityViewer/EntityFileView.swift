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
    #endif

    var body: some View
    {
        #if os(macOS) || os(iOS)
        RealityView
        { content in
            // Duplicate entity
            if previewed_entity == nil, let entity = entity
            {
                previewed_entity = entity.clone(recursive: true)
            }
            
            if let previewed_entity = previewed_entity
            {
                content.add(previewed_entity)
                
                // Camera reposition
                let bounds = previewed_entity.visualBounds(relativeTo: nil).extents
                let camera = PerspectiveCamera()
                camera.position = [0, bounds.y / 2, bounds.z * 2]
                content.add(camera)
            }
        }
        .realityViewCameraControls(.orbit)
        #if os(iOS)
        .background(.white)
        #endif
        .onDisappear
        {
            previewed_entity = nil
        }
        #else
        DesignRealityView(entity: entity)
        #endif
    }
}

#Preview
{
    EntityFileView(entity: ModelEntity(
        mesh: .generateBox(size: 1.0, cornerRadius: 0.1),
        materials: [SimpleMaterial(color: .white, isMetallic: false)]))
}
