//
//  BuildListView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

struct BuildListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var selected_name: String
    
    @State private var targets_palette_view_presented = false
    //@State private var selected_name = String()
    @State private var new_panel_presented = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                Picker(selection: $selected_name, label: Text("List"))
                {
                    ForEach (base_stc.package_info.build_modules_lists_names, id: \.self)
                    { name in
                        Text(name)
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(base_stc.package_info.build_modules_lists.count == 0)
                #if os(iOS)
                .modifier(PickerBorderer())
                #endif
                
                #if os(macOS)
                Button("-")
                {
                    delete_modules_list(selected_name)
                }
                
                Button("+")
                {
                    new_panel_presented = true
                }
                .popover(isPresented: $new_panel_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                    { new_name in
                        add_modules_list(new_name)
                    }
                }
                #else
                Button(action: {delete_modules_list(selected_name)})
                {
                    Image(systemName: "minus")
                }
                .frame(width: 32, height: 32)
                #if os(visionOS)
                .padding(.trailing)
                #endif
                
                Button(action:{new_panel_presented = true})
                {
                    Image(systemName: "plus")
                }
                .frame(width: 32, height: 32)
                .popover(isPresented: $new_panel_presented, arrowEdge: default_popover_edge_inverted)
                {
                    AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                    { new_name in
                        add_modules_list(new_name)
                    }
                }
                #endif
            }
            .padding(.bottom)
            
            List
            {
                if selected_list_index != -1
                {
                    DisclosureGroup("Robot")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.robot_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.robot_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Tool")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.tool_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.tool_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Part")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.part_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.part_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Changer")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.changer_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.changer_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .modifier(ListBorderer())
            // .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: Module lists handling
    private func add_modules_list(_ name: String)
    {
        base_stc.package_info.build_modules_lists.append(BuildModulesList(name: name))
        selected_name = base_stc.package_info.build_modules_lists_names.last ?? ""
    }
    
    private func delete_modules_list(_ name: String)
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return
        }
        
        base_stc.package_info.build_modules_lists.remove(at: index)
        
        selected_name = base_stc.package_info.build_modules_lists_names.last ?? ""
    }
    
    private var selected_list_index: Int
    {
        return base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
    
    private var selected_list: BuildModulesList
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return BuildModulesList(name: "")
        }
        return base_stc.package_info.build_modules_lists[index]
    }
    
    // MARK: Module names handling
    private func add_module_name(_ name: String, names: inout [String])
    {
        guard let _ = names.firstIndex(where: { $0 == name })
        else
        {
            names.append(name)
            return
        }
    }
    
    private func delete_module_name(at offsets: IndexSet, names: inout [String])
    {
        withAnimation
        {
            names.remove(atOffsets: offsets)
        }
    }
}

#Preview
{
    BuildListView(selected_name: .constant("UwU"))
        .environmentObject(StandardTemplateConstruct())
}
