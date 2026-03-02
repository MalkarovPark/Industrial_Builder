//
//  RobotModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct RobotModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
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
                        ForEach(base_stc.robot_modules)
                        { module in
                            RobotModuleCard(module: module)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
                .animation(.spring(), value: base_stc.robot_modules)
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
            }
        }
        .toolbar
        {
            ToolbarItem(id: "Add Module", placement: trailing_placement)
            {
                Button(action: { new_module_view_presented = true })
                {
                    Label("Add Object", systemImage: "plus")
                }
                .popover(isPresented: $new_module_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.robot_modules_names)
                    { new_name in
                        base_stc.robot_modules.append(RobotModule(new_name: new_name))
                        document_handler.document_update_robots()
                    }
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

struct RobotModuleCard: View
{
    @ObservedObject var module: RobotModule
    
    @State private var to_rename = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        NavigationLink(destination: RobotModuleDesigner(module: module))
        {
            if let entity_file_name = module.entity_file_name,
               let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
            {
                GlassBoxCard(
                    title: module.name,
                    entity: entity_file_item.entity,
                    vertical_repostion: true,
                    to_rename: $to_rename,
                    edited_name: $module.name,
                    on_rename:
                        {
                            document_handler.document_update_robots()
                            to_rename = false
                        }
                )
            }
            else
            {
                GlassBoxCard(
                    title: module.name,
                    symbol_name: "r.square",
                    symbol_size: 64,
                    symbol_weight: .regular,
                    to_rename: $to_rename,
                    edited_name: $module.name,
                    on_rename:
                        {
                            document_handler.document_update_robots()
                            to_rename = false
                        }
                )
            }
        }
        .frame(height: 192)
        .contextMenu
        {
            RenameButton()
                .renameAction
            {
                withAnimation
                {
                    to_rename = true
                }
            }
            
            Button(role: .destructive, action: { delete_module(module) })
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func delete_module(_ module: RobotModule)
    {
        base_stc.robot_modules.removeAll { $0 == module }
        document_handler.document_update_robots()
    }
}

#Preview
{
    RobotModulesView()
}
