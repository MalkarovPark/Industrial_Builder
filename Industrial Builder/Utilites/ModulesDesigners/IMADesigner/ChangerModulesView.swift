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
    
    @State private var selected_name = String()
    
    @State private var smi = -1
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                ModulesListView(names: $base_stc.changer_modules_names, selected_name: $selected_name)
                { name in
                    base_stc.changer_modules.append(ChangerModule(new_name: name))
                }
                rename_module:
                { new_name in
                    base_stc.changer_modules[selected_module_index()].name = new_name
                    document_handler.document_update_ima()
                }
                delete_module:
                {
                    base_stc.changer_modules.remove(at: selected_module_index())
                }
                
                VStack(spacing: 0)
                {
                    if smi != -1
                    {
                        ChangerModuleDesigner(changer_module: $base_stc.changer_modules[smi])
                            .modifier(ViewBorderer())
                    }
                    else
                    {
                        GroupBox
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
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
        .modifier(WindowFramer())
        .onChange(of: base_stc.changer_modules)
        {
            document_handler.document_update_ima()
        }
        .onChange(of: selected_name)
        {
            smi = selected_module_index()
        }
    }
    
    private func selected_module_index() -> Int
    {
        return base_stc.changer_modules.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
}

#Preview
{
    ChangerModulesView()
        .environmentObject(StandardTemplateConstruct())
}
