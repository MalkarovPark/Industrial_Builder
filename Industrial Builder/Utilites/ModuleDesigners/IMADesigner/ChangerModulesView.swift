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
    
    @State private var search_text: String = String()
    
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
                        ForEach(filtered_modules)
                        { module in
                            ChangerModuleCard(module: module)
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
                Button
                {
                    base_stc.changer_modules.append(ChangerModule(external_name: unique_name(for: "Changer", in: base_stc.changer_module_names)))
                    document_handler.document_update_changers()
                }
                label:
                {
                    Label("Add Object", systemImage: "plus")
                }
            }
        }
    }
    
    private var filtered_modules: [ChangerModule]
    {
        if search_text.isEmpty
        {
            return base_stc.changer_modules
        }
        
        return base_stc.changer_modules.filter
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

private struct ChangerModuleCard: View
{
    @ObservedObject var module: ChangerModule
    
    @State private var is_renaming = false
    
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
                is_renaming: $is_renaming,
                on_rename: { new_name in on_rename(new_name) }
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
                        is_renaming = true
                    }
                }
            
            Button(role: .destructive, action: { delete_module(module) })
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func on_rename(_ new_name: String)
    {
        if !new_name.isEmpty
        {
            let unique_name = unique_name(for: new_name, in: base_stc.changer_module_names.filter { $0 != module.name })
            
            if module.name != unique_name
            {
                module.name = unique_name
                document_handler.document_update_changers()
            }
        }
        
        is_renaming = false
    }
    
    private func delete_module(_ module: ChangerModule)
    {
        base_stc.changer_modules.removeAll { $0 == module }
        document_handler.document_update_changers()
    }
}

#Preview
{
    ChangerModulesView()
        .environmentObject(StandardTemplateConstruct())
}
