//
//  ToolModulesEditor.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit

struct ToolModulesEditor: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var selected_name = String()
    @State private var smi = -1
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                ModulesListView(names: $base_stc.tool_modules_names, selected_name: $selected_name)
                { name in
                    base_stc.tool_modules.append(ToolModule(name: name))
                }
                rename_module:
                { new_name in
                    base_stc.tool_modules[selected_module_index()].name = new_name
                    //document_handler.document_update_tools()
                }
                delete_module:
                {
                    base_stc.tool_modules.remove(at: selected_module_index())
                }
                
                VStack(spacing: 0)
                {
                    if smi != -1
                    {
                        if smi != -2
                        {
                            ToolsModuleView(tool_module: $base_stc.tool_modules[smi])
                                //.modifier(ListBorderer())
                        }
                        else
                        {
                            //ChangerModuleView(changer_module: .constant(ChangerModule()))
                            GroupBox
                            {
                                ZStack
                                {
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    else
                    {
                        GroupBox
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
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
        .modifier(WindowFramer())
        .onChange(of: base_stc.tool_modules)
        {
            //document_handler.document_update_tools()
        }
        .onChange(of: selected_name)
        {
            smi = -2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                smi = selected_module_index()
            }
        }
    }
    
    private func selected_module_index() -> Int
    {
        return base_stc.tool_modules.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
}

#Preview
{
    ToolModulesEditor()
        .environmentObject(StandardTemplateConstruct())
}
