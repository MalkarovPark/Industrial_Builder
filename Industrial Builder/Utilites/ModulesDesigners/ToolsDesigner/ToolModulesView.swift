//
//  ToolModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit

struct ToolModulesView: View
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
                ModulesListView(names: $base_stc.tool_modules_names, selected_name: $selected_name)
                { name in
                    base_stc.tool_modules.append(ToolModule(new_name: name))
                }
                rename_module:
                { new_name in
                    base_stc.tool_modules[selected_module_index()].name = new_name
                    document_handler.document_update_tools()
                }
                delete_module:
                {
                    base_stc.tool_modules.remove(at: selected_module_index())
                }
                
                VStack(spacing: 0)
                {
                    if selected_module_index() != -1
                    {
                        ToolModuleDesigner(tool_module: $base_stc.tool_modules[selected_module_index()])
                            .modifier(ViewBorderer())
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
            document_handler.document_update_tools()
        }
    }
    
    private func selected_module_index() -> Int
    {
        return base_stc.tool_modules.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
}

#Preview
{
    ToolModulesView()
        .environmentObject(StandardTemplateConstruct())
}
