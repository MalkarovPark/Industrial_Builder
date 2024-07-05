//
//  ToolModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 11.05.2024.
//

import SwiftUI
import IndustrialKit

struct ToolModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var tool_module: ToolModule
    
    @State private var editor_selection = 0
    
    @State private var resources_names_update = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $editor_selection, label: Text("Picker"))
            {
                Text("Description").tag(0)
                Text("Operations").tag(1)
                Text("Code").tag(2)
                Text("Resources").tag(3)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $tool_module.description)
                    .textFieldStyle(.plain)
            case 1:
                OperationCodesEditor(tool_operations: $tool_module.operation_codes)
            case 2:
                CodeEditorView(code_items: $tool_module.code_items)
                {
                    document_handler.document_update_tools()
                }
            default:
                ResourcesPackageView(resources_names: $tool_module.resources_names, main_scene_name: $tool_module.main_scene_name)
                {
                    document_handler.document_update_tools()
                }
            }
        }
        .background(.white)
    }
}

#Preview
{
    ToolModuleDesigner(tool_module: .constant(ToolModule()))
        .environmentObject(StandardTemplateConstruct())
}
