//
//  PartModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 17.04.2024.
//

import SwiftUI
import IndustrialKit

struct PartModulesView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var new_module_view_presented: Bool = false
    @State private var selection: PartModule.ID?
    @State private var rename_item: PartModule.ID?
    @State private var new_name = ""
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            // MARK: - List View
            List(selection: $selection)
            {
                ForEach($base_stc.part_modules)
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
                            if let index = base_stc.part_modules.firstIndex(where: { $0.id == item.id })
                            {
                                base_stc.part_modules.remove(at: index)
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
                            if let index = base_stc.part_modules.firstIndex(where: { $0.id == item.id })
                            {
                                base_stc.part_modules.remove(at: index)
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
            .onChange(of: base_stc.part_modules)
            { _, _ in
                document_handler.document_update_parts()
            }
            
            #if !os(visionOS)
            Divider()
            #endif
            
            // MARK: - Detail View
            if let selected_item_id = selection, let selected_module_index = base_stc.part_modules.firstIndex(where: { $0.id == selected_item_id })
            {
                PartModuleDesigner(part_module: $base_stc.part_modules[selected_module_index])
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No module selected", systemImage: "shippingbox")
                }
                description:
                {
                    Text("Select an existing part module to edit.")
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
                #if os(visionOS)
                .buttonBorderShape(.circle)
                #endif
                .popover(isPresented: $new_module_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_module_view_presented, names: base_stc.part_modules_names)
                    { new_name in
                        base_stc.part_modules.append(PartModule(new_name: new_name))
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
    PartModulesView()
        .environmentObject(StandardTemplateConstruct())
}
