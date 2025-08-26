//
//  ToolModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct ToolModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    @State private var selection: ToolModule.ID?
    @State private var rename_item: ToolModule.ID?
    @State private var new_name = ""
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    
    @State private var picker_in_rename: Bool = false
    #endif
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            if sidebar_enabled
            {
                // MARK: - List View
                List(selection: $selection)
                {
                    ForEach($base_stc.tool_modules)
                    { $item in
                        HStack
                        {
                            if rename_item == item.id
                            {
                                TextField("Input new name", text: $new_name)
                                    .onSubmit
                                {
                                    item.name = new_name
                                    document_handler.document_update_tools()
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
                                if let index = base_stc.tool_modules.firstIndex(where: { $0.id == item.id })
                                {
                                    base_stc.tool_modules.remove(at: index)
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
                                if let index = base_stc.tool_modules.firstIndex(where: { $0.id == item.id })
                                {
                                    base_stc.tool_modules.remove(at: index)
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
                #elseif os(iOS)
                .frame(maxWidth: 192)
                #else
                .frame(maxWidth: 256)
                .background(.thinMaterial)
                #endif
                .listStyle(.plain)
            }
            
            #if !os(visionOS)
            Divider()
            #endif
            
            // MARK: - Detail View
            if let selected_item_id = selection, let selected_module_index = base_stc.tool_modules.firstIndex(where: { $0.id == selected_item_id })
            {
                ToolModuleDesigner(tool_module: $base_stc.tool_modules[selected_module_index])
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No module selected", systemImage: "hammer")
                }
                description:
                {
                    Text("Select an existing tool module to edit.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #if !os(visionOS)
                .background(.white)
                #endif
            }
        }
        .onChange(of: base_stc.tool_modules)
        { _, _ in
            document_handler.document_update_tools()
        }
        #if os(iOS)
        .onAppear
        {
            if horizontal_size_class == .compact && base_stc.tool_modules.count > 0
            {
                selection = base_stc.tool_modules.first?.id
            }
        }
        .onChange(of: horizontal_size_class)
        { _, new_value in
            if new_value == .compact && base_stc.tool_modules.count > 0 && selection == nil
            {
                selection = base_stc.tool_modules.first?.id
            }
            
            if new_value != .compact
            {
                picker_in_rename = false
            }
        }
        #endif
        .toolbar
        {
            ToolbarItem
            {
                Button(action: { new_module_view_presented = true })
                {
                    Image(systemName: "plus")
                }
                #if os(visionOS)
                .buttonBorderShape(.circle)
                #endif
                .popover(isPresented: $new_module_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.tool_modules_names)
                    { new_name in
                        base_stc.tool_modules.append(ToolModule(new_name: new_name))
                        selection = base_stc.tool_modules.last?.id
                    }
                }
            }
            
            #if os(iOS)
            if horizontal_size_class == .compact && base_stc.tool_modules.count > 0
            {
                ToolbarItem(placement: .bottomBar)
                {
                    HStack
                    {
                        if picker_in_rename
                        {
                            TextField("Input new name", text: $new_name)
                                .onSubmit
                            {
                                if let selected_module_index = base_stc.tool_modules.firstIndex(where: { $0.id == selection })
                                {
                                    base_stc.tool_modules[selected_module_index].name = new_name
                                }
                                
                                document_handler.document_update_tools()
                                picker_in_rename = false
                                new_name = ""
                            }
                        }
                        else
                        {
                            Picker(selection: $selection, label: Text("Picker"))
                            {
                                ForEach($base_stc.tool_modules)
                                { $item in
                                    Text(item.name)
                                        .tag(item.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        
                        Button
                        {
                            picker_in_rename = true
                            if let selected_module_index = base_stc.tool_modules.firstIndex(where: { $0.id == selection })
                            {
                                new_name = base_stc.tool_modules[selected_module_index].name
                            }
                        }
                        label:
                        {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive)
                        {
                            if let index = base_stc.tool_modules.firstIndex(where: { $0.id == selection })
                            {
                                base_stc.tool_modules.remove(at: index)
                                
                                if base_stc.tool_modules.count > 0
                                {
                                    selection = base_stc.tool_modules.first?.id
                                }
                            }
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(picker_in_rename)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            #endif
        }
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }
    
    private var sidebar_enabled: Bool
    {
        #if !os(iOS)
        return true
        #else
        return horizontal_size_class != .compact
        #endif
    }
}

#Preview
{
    ToolModulesView()
        .environmentObject(StandardTemplateConstruct())
}
