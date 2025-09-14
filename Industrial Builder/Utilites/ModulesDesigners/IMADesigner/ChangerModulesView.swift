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
    @State private var selection: ChangerModule.ID?
    @State private var rename_item: ChangerModule.ID?
    @State private var new_name = ""
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    
    @State private var picker_in_rename: Bool = false
    #endif
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            #if !os(macOS)
            Divider()
                .hidden()
            #endif
            
            if sidebar_enabled
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
                                TextField("None", text: $new_name)
                                    .onSubmit
                                {
                                    item.name = new_name
                                    document_handler.document_update_ima()
                                    rename_item = nil
                                    new_name = "None"
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
                        #if os(visionOS)
                        .listRowBackground(selection == item.id ? Color.accentColor.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous)) : Color.clear.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)))
                        #endif
                    }
                }
                #if os(macOS)
                .frame(maxWidth: 128)
                #elseif os(iOS)
                .frame(maxWidth: 192)
                #elseif os(visionOS)
                .frame(maxWidth: 256)
                .background(.thinMaterial)
                #endif
                .listStyle(.plain)
            }
            
            #if !os(visionOS)
            Divider()
            #endif
            
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
        .onChange(of: base_stc.changer_modules)
        { _, _ in
            document_handler.document_update_ima()
        }
        #if os(iOS)
        .onAppear
        {
            if horizontal_size_class == .compact && base_stc.changer_modules.count > 0
            {
                selection = base_stc.changer_modules.first?.id
            }
        }
        .onChange(of: horizontal_size_class)
        { _, new_value in
            if new_value == .compact && base_stc.changer_modules.count > 0 && selection == nil
            {
                selection = base_stc.changer_modules.first?.id
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
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.changer_modules_names)
                    { new_name in
                        base_stc.changer_modules.append(ChangerModule(new_name: new_name))
                        selection = base_stc.changer_modules.last?.id
                    }
                }
            }
            
            #if os(iOS)
            if horizontal_size_class == .compact && base_stc.changer_modules.count > 0
            {
                ToolbarItem(placement: .bottomBar)
                {
                    HStack
                    {
                        if picker_in_rename
                        {
                            TextField("None", text: $new_name)
                                .onSubmit
                            {
                                if let selected_module_index = base_stc.changer_modules.firstIndex(where: { $0.id == selection })
                                {
                                    base_stc.changer_modules[selected_module_index].name = new_name
                                }
                                
                                document_handler.document_update_ima()
                                picker_in_rename = false
                                new_name = "None"
                            }
                        }
                        else
                        {
                            Picker(selection: $selection, label: Text("Picker"))
                            {
                                ForEach($base_stc.changer_modules)
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
                            if let selected_module_index = base_stc.changer_modules.firstIndex(where: { $0.id == selection })
                            {
                                new_name = base_stc.changer_modules[selected_module_index].name
                            }
                        }
                        label:
                        {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive)
                        {
                            if let index = base_stc.changer_modules.firstIndex(where: { $0.id == selection })
                            {
                                base_stc.changer_modules.remove(at: index)
                                
                                if base_stc.changer_modules.count > 0
                                {
                                    selection = base_stc.changer_modules.first?.id
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
    ChangerModulesView()
        .environmentObject(StandardTemplateConstruct())
}
