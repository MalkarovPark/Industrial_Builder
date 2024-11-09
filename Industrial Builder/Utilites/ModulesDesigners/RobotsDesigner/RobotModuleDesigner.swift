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
    
    @State private var linked_components_view_presented: Bool = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                Picker(selection: $editor_selection, label: Text("Picker"))
                {
                    Text("Description").tag(0)
                    Text("Code").tag(1)
                    Text("Resources").tag(2)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.trailing)
                
                Button("Linked")
                {
                    linked_components_view_presented.toggle()
                }
                .popover(isPresented: $linked_components_view_presented, arrowEdge: .bottom)
                {
                    LinkedComponentsView(linked_components: $robot_module.linked_components)
                    {
                        document_handler.document_update_robots()
                    }
                }
            }
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $robot_module.description)
                    .textFieldStyle(.plain)
            case 1:
                CodeEditorView(code_items: $robot_module.code_items, avaliable_templates_names: [
                    "Controller": ["Internal Robot Controller", "External Robot Controller"],
                    "Connector": ["Internal Robot Connector", "External Robot Connector"]
                ])
                {
                    document_handler.document_update_tools()
                }
            case 2:
                ResourcesPackageView(resources_names: $robot_module.resources_names, main_scene_name: $robot_module.main_scene_name, nodes_names: $robot_module.nodes_names)
                {
                    document_handler.document_update_tools()
                }
            default:
                EmptyView()
            }
        }
        .background(.white)
    }
}

#Preview
{
    RobotModuleDesigner(robot_module: .constant(RobotModule()))
}
