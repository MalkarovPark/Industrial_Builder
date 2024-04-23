//
//  PartsModulesEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 17.04.2024.
//

import SwiftUI

struct PartsModulesEditor: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var selected_name = String()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                ModulesListView(names: $base_stc.part_modules_names, selected_name: $selected_name)
                { name in
                    base_stc.part_modules.append(PartModule(name: name))
                }
                remove_module:
                {
                    base_stc.part_modules.remove(at: selected_module_index())
                }
                
                VStack(spacing: 0)
                {
                    if selected_module_index() != -1
                    {
                        PartsModuleView(part_module: $base_stc.part_modules[selected_module_index()])
                    }
                    else
                    {
                        GroupBox
                        {
                            Text("Select Module")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(ListBorderer())
            }
            .padding()
        }
        .modifier(WindowFramer())
        .onChange(of: base_stc.part_modules)
        {
            document_handler.document_update_parts()
        }
    }
    
    private func selected_module_index() -> Int
    {
        return base_stc.part_modules.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
}

#Preview
{
    PartsModulesEditor()
}
