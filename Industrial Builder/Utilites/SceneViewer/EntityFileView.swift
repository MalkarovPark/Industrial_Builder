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
    
    @State private var preview_entity: Entity?

    var body: some View
    {
        RealityView
        { content in
            // Duplicate entity
            if preview_entity == nil, let entity = entity
            {
                preview_entity = entity.clone(recursive: true)
            }

            if let preview_entity = preview_entity
            {
                content.add(preview_entity)
                
                // Camera reposition
                let bounds = preview_entity.visualBounds(relativeTo: nil).extents
                let camera = PerspectiveCamera()
                camera.position = [0, bounds.y / 2, bounds.z * 2]
                content.add(camera)
            }
        }
        .realityViewCameraControls(.orbit)
        .onDisappear
        {
            preview_entity = nil
        }
    }
}

#Preview
{
    EntityFileView(entity: ModelEntity(
        mesh: .generateBox(size: 1.0, cornerRadius: 0.1),
        materials: [SimpleMaterial(color: .white, isMetallic: false)]))
}
