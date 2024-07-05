//
//  RobotModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 26.06.2024.
//

import SwiftUI
import IndustrialKit

struct RobotModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var robot_module: RobotModule
    
    @State private var editor_selection = 0
    
    @State private var resources_names_update = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $editor_selection, label: Text("Picker"))
            {
                Text("Description").tag(0)
                Text("Code").tag(1)
                Text("Resources").tag(2)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $robot_module.description)
                    .textFieldStyle(.plain)
            case 1:
                CodeEditorView(code_items: $robot_module.code_items)
                {
                    document_handler.document_update_tools()
                }
            default:
                ResourcesPackageView(resources_names: $robot_module.resources_names, main_scene_name: $robot_module.main_scene_name)
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
    RobotModuleDesigner(robot_module: .constant(RobotModule()))
}
