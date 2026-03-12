//
//  ChangerModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 18.04.2024.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct ChangerModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        NavigationStack
        {
            if base_stc.changer_modules.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.changer_modules)
                        { module in
                            ChangerModuleCard(module: module)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                }
                .animation(.spring(), value: base_stc.changer_modules)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No changer modules", systemImage: "wand.and.rays")
                }
                description:
                {
                    Text("""
                         Press "+" to add new changer module.
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
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.changer_modules_names)
                    { new_name in
                        base_stc.changer_modules.append(ChangerModule(external_name: new_name))
                        document_handler.document_update_ima()
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

struct ChangerModuleCard: View
{
    @ObservedObject var module: ChangerModule
    
    @State private var to_rename = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        NavigationLink(destination: ChangerModuleDesigner(module: module))
        {
            GlassBoxCard(
                title: module.name,
                symbol_name: "wand.and.rays",
                symbol_size: 64,
                symbol_weight: .regular,
                to_rename: $to_rename,
                edited_name: $module.name,
                on_rename:
                    {
                        document_handler.document_update_ima()
                        to_rename = false
                    }
            )
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
    
    private func delete_module(_ module: ChangerModule)
    {
        base_stc.changer_modules.removeAll { $0 == module }
        document_handler.document_update_ima()
    }
}

#Preview
{
    ChangerModulesView()
        .environmentObject(StandardTemplateConstruct())
}
