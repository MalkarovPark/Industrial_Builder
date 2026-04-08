//
//  EntityCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct EntityCard<Content: View>: View
{
    let entity_item: EntityItem
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    //@State private var is_renaming: Bool = false
    
    var body: some View
    {
        Button(action: { is_presented = true })
        {
            GlassBoxCard(
                title: entity_item.name,
                entity: entity_item.entity,
                vertical_repostion: true//,
                //is_renaming: $is_renaming,
                //on_rename: { new_name in on_rename(new_name) }
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .frame(height: 192)
        .contextMenu
        {
            /*RenameButton()
                .renameAction
            {
                withAnimation
                {
                    is_renaming = true
                }
            }*/
            
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
    
    /*private func on_rename(_ new_name: String)
    {
        if !new_name.isEmpty
        {
            let unique_name = unique_name(
                for: new_name,
                in: base_stc.entity_item_names.filter { $0 != entity_item.name }
            )
            
            if entity_item.name != unique_name
            {
                entity_item.name = unique_name
                document_handler.document_update_entities()
            }
        }
        
        is_renaming = false
    }*/
    
    private func delete_scene()
    {
        base_stc.entity_items.removeAll { $0 == entity_item }
        document_handler.update_entities()
    }
}

#Preview
{
    EntityCard(entity_item: EntityItem(name: "Entity", entity: ModelEntity(mesh: .generateBox(size: 1.0, cornerRadius: 0.1), materials: [SimpleMaterial(color: .white, isMetallic: false)])))
    { is_presented in
        EmptyView()
    }
    .frame(width: 256)
    .padding()
}
