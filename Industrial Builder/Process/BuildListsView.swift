//
//  BuildListsView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 02.05.2025.
//

import SwiftUI
import IndustrialKit

struct BuildListsView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var selected_name: String
    
    @State private var targets_palette_view_presented = false
    @State private var new_panel_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 8)]
    
    var body: some View
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
        .padding()
        
        BuildListView(selected_name: $selected_name)
            /*.onChange(of: base_stc.package_info.build_modules_lists)
            { _, _ in
                document_handler.document_update_info()
            }*/
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
}

#Preview
{
    BuildListsView(selected_name: .constant("UwU"))
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
        .padding()
}
