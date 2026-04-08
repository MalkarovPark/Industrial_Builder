//
//  RobotModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct RobotModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    @State private var search_text: String = String()
    
    var body: some View
    {
        NavigationStack
        {
            if base_stc.robot_modules.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(filtered_modules)
                        { module in
                            RobotModuleCard(module: module)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
                .animation(.spring(), value: filtered_modules)
                .searchable(text: $search_text)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No robot modules", systemImage: "r.square")
                }
                description:
                {
                    Text("""
                         Press "+" to add new robot module.
                         """)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .searchable(text: $search_text)
            }
        }
        .toolbar
        {
            ToolbarItem(id: "Add Module", placement: trailing_placement)
            {
                Button
                {
                    base_stc.robot_modules.append(RobotModule(new_name: unique_name(for: "Robot", in: base_stc.robot_module_names)))
                    document_handler.update_robots()
                }
                label:
                {
                    Label("Add Object", systemImage: "plus")
                }
            }
        }
    }
    
    private var filtered_modules: [RobotModule]
    {
        if search_text.isEmpty
        {
            return base_stc.robot_modules
        }
        
        return base_stc.robot_modules.filter
        {
            $0.name.localizedCaseInsensitiveContains(search_text)
        }
    }
    
    #if os(macOS)
    private var trailing_placement: ToolbarItemPlacement = .confirmationAction
    #else
    private var trailing_placement: ToolbarItemPlacement = .topBarTrailing
    #endif
}

private struct RobotModuleCard: View
{
    @ObservedObject var module: RobotModule
    
    @State private var is_renaming = false
    @State private var preview_entity: Entity?
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var view_id = UUID()
    
    var body: some View
    {
        NavigationLink(destination: RobotModuleDesigner(module: module).onDisappear(perform: reset_card))
        {
            if preview_entity != nil
            {
                GlassBoxCard(
                    title: module.name,
                    entity: preview_entity,
                    vertical_repostion: true,
                    is_renaming: $is_renaming,
                    on_rename: { new_name in on_rename(new_name) }
                )
            }
            else
            {
                GlassBoxCard(
                    title: module.name,
                    symbol_name: "r.square",
                    symbol_size: 64,
                    symbol_weight: .regular,
                    is_renaming: $is_renaming,
                    on_rename: { new_name in on_rename(new_name) }
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
    
    private func on_rename(_ new_name: String)
    {
        if !new_name.isEmpty
        {
            let unique_name = unique_name(for: new_name, in: base_stc.robot_module_names.filter { $0 != module.name })
            if module.name != unique_name
            {
                module.name = unique_name
                document_handler.update_robots()
            }
        }
        
        is_renaming = false
    }
    
    private func delete_module(_ module: RobotModule)
    {
        base_stc.robot_modules.removeAll { $0 == module }
        document_handler.update_robots()
    }
}

#Preview
{
    RobotModulesView()
}
