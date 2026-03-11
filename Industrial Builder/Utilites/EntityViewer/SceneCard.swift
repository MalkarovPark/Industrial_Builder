//
//  SceneCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKitUI

struct SceneCard<Content: View>: View
{
    let entity_item: EntityItem
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        Button(action: { is_presented = true })
        {
            GlassBoxCard(
                title: entity_item.name,
                entity: entity_item.entity,
                vertical_repostion: true
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .frame(height: 192)
        .contextMenu
        {
            Button(role: .destructive)
            {
                delete_scene()
            }
            label:
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func delete_scene()
    {
        base_stc.entity_items.removeAll { $0 == entity_item }
        document_handler.document_update_scenes()
    }
}

#Preview
{
    SceneCard(entity_item: EntityItem(name: "Entity", entity: ModelEntity(mesh: .generateBox(size: 1.0, cornerRadius: 0.1), materials: [SimpleMaterial(color: .white, isMetallic: false)])))
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
    .padding()
}
