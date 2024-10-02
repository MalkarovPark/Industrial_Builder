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
    
    @State private var selected_name = String()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                ModulesListView(names: $base_stc.part_modules_names, selected_name: $selected_name)
                { name in
                    base_stc.part_modules.append(PartModule(new_name: name))
                }
                rename_module:
                { new_name in
                    base_stc.part_modules[selected_module_index()].name = new_name
                    document_handler.document_update_parts()
                }
                delete_module:
                {
                    base_stc.part_modules.remove(at: selected_module_index())
                }
                
                VStack(spacing: 0)
                {
                    if selected_module_index() != -1
                    {
                        PartModuleDesigner(part_module: $base_stc.part_modules[selected_module_index()])
                            .modifier(ViewBorderer())
                    }
                    else
                    {
                        GroupBox
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
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    PartModulesView()
        .environmentObject(StandardTemplateConstruct())
}
