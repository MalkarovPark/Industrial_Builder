//
//  ChangerModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 18.04.2024.
//

import SwiftUI
import IndustrialKit

struct ChangerModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    @State private var selection: ChangerModule.ID?
    @State private var rename_item: ChangerModule.ID?
    @State private var new_name = ""
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            // MARK: - List View
            List(selection: $selection)
            {
                ForEach($base_stc.changer_modules)
                { $item in
                    HStack
                    {
                        if rename_item == item.id
                        {
                            TextField("Input New Name", text: $new_name)
                                .onSubmit
                            {
                                item.name = new_name
                                rename_item = nil
                                new_name = ""
                            }
                        }
                        else
                        {
                            Text(item.name)
                        }
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .contextMenu
                    {
                        Button
                        {
                            rename_item = item.id
                            new_name = item.name
                        }
                        label:
                        {
                            Label("Rename", systemImage: "pencil")
                        }
                        Button(role: .destructive)
                        {
                            if let index = base_stc.changer_modules.firstIndex(where: { $0.id == item.id })
                            {
                                base_stc.changer_modules.remove(at: index)
                            }
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions
                    {
                        Button(role: .destructive)
                        {
                            if let index = base_stc.changer_modules.firstIndex(where: { $0.id == item.id })
                            {
                                base_stc.changer_modules.remove(at: index)
                            }
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            #if os(macOS)
            .frame(maxWidth: 128)
            #else
            .frame(maxWidth: 192)
            #endif
            .listStyle(.plain)
            
            Divider()
            
            // MARK: - Detail View
            if let selected_item_id = selection, let selected_module_index = base_stc.changer_modules.firstIndex(where: { $0.id == selected_item_id })
            {
                ChangerModuleDesigner(changer_module: $base_stc.changer_modules[selected_module_index])
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No module selected", systemImage: "wand.and.rays")
                }
                description:
                {
                    Text("Select an existing changer module to edit.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if !os(visionOS)
                .background(.white)
                #endif
            }
        }
        .toolbar
        {
            ToolbarItem
            {
                Button(action: { new_module_view_presented = true })
                {
                    Image(systemName: "plus")
                }
                .popover(isPresented: $new_module_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.changer_modules_names)
                    { new_name in
                        base_stc.changer_modules.append(ChangerModule(new_name: new_name))
                    }
                }
            }
        }
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }
    
    
}

#Preview
{
    ChangerModulesView()
        .environmentObject(StandardTemplateConstruct())
}
