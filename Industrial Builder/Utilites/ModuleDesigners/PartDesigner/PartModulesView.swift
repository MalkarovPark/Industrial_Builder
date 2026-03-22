//
//  PartModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 17.04.2024.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct PartModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        NavigationStack
        {
            if base_stc.part_modules.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.part_modules)
                        { module in
                            PartModuleCard(module: module)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
                .animation(.spring(), value: base_stc.part_modules)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No part modules", systemImage: "shippingbox")
                }
                description:
                {
                    Text("""
                         Press "+" to add new part module.
                         """)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar
        {
            ToolbarItem(id: "Add Module", placement: trailing_placement)
            {
                Button
                {
                    base_stc.part_modules.append(PartModule(new_name: unique_name(for: "Part", in: base_stc.part_module_names)))
                    document_handler.document_update_parts()
                }
                label:
                {
                    Label("Add Object", systemImage: "plus")
                }
            }
        }
    }
    
    #if os(macOS)
    private var trailing_placement: ToolbarItemPlacement = .confirmationAction
    #else
    private var trailing_placement: ToolbarItemPlacement = .topBarTrailing
    #endif
}

struct PartModuleCard: View
{
    @ObservedObject var module: PartModule
    
    @State private var is_renaming = false
    @State private var preview_entity: Entity?
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var view_id = UUID()
    
    var body: some View
    {
        NavigationLink(destination: PartModuleDesigner(module: module).onDisappear(perform: reset_card))
        {
            if preview_entity != nil
            {
                GlassBoxCard(
                    title: module.name,
                    entity: preview_entity,
                    vertical_repostion: true,
                    is_renaming: $is_renaming,
                    on_rename:
                        { new_name in
                            module.name = unique_name(for: new_name, in: base_stc.part_module_names)
                            document_handler.document_update_parts()
                            is_renaming = false
                        }
                )
            }
            else
            {
                GlassBoxCard(
                    title: module.name,
                    symbol_name: "shippingbox",
                    symbol_size: 64,
                    symbol_weight: .regular,
                    is_renaming: $is_renaming,
                    on_rename:
                        { new_name in
                            module.name = unique_name(for: new_name, in: base_stc.part_module_names)
                            document_handler.document_update_parts()
                            is_renaming = false
                        }
                )
            }
        }
        .id(view_id)
        .frame(height: 192)
        .contextMenu
        {
            RenameButton()
                .renameAction
            {
                withAnimation
                {
                    is_renaming = true
                }
            }
            
            Button(role: .destructive, action: { delete_module(module) })
            {
                Label("Delete", systemImage: "trash")
            }
        }
        .onAppear
        {
            load_entity()
        }
        .onDisappear
        {
            preview_entity = nil
        }
    }
    
    private func load_entity()
    {
        if let entity_file_name = module.entity_file_name,
           let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
        {
            preview_entity = entity_file_item.entity.clone(recursive: true)
        }
        else
        {
            preview_entity = nil
        }
    }
    
    private func reset_card()
    {
        view_id = UUID()
        load_entity()
    }
    
    private func delete_module(_ module: PartModule)
    {
        base_stc.part_modules.removeAll { $0 == module }
        document_handler.document_update_parts()
    }
}

#Preview
{
    PartModulesView()
        .environmentObject(StandardTemplateConstruct())
}
