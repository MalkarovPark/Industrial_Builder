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
    
    @State private var connection_parameters_view_presented: Bool = false
    @State private var linked_components_view_presented: Bool = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                #if !os(iOS)
                Picker(selection: $editor_selection, label: Text("Picker"))
                {
                    Text("Description").tag(0)
                    Text("Operations").tag(1)
                    Text("Code").tag(2)
                    Text("Resources").tag(3)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.trailing)
                #else
                if horizontal_size_class != .compact
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
                    .padding(.trailing)
                }
                else
                {
                    Picker(selection: $editor_selection, label: Text("Picker"))
                    {
                        Text("Description").tag(0)
                        Text("Operations").tag(1)
                        Text("Code").tag(2)
                        Text("Resources").tag(3)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .modifier(PickerBorderer())
                    .padding(.trailing)
                }
                #endif
                
                Button(action: { connection_parameters_view_presented.toggle() })
                {
                    Image(systemName: "link")
                }
                #if os(iOS)
                .frame(width: 32, height: 32)
                .modifier(ButtonBorderer())
                #endif
                .popover(isPresented: $connection_parameters_view_presented, arrowEdge: .top)
                {
                    ConnectionParametersView(connection_parameters: $tool_module.connection_parameters)
                    {
                        document_handler.document_update_tools()
                    }
                }
                .padding(.trailing)
                
                Button(action: { linked_components_view_presented.toggle() })
                {
                    Image(systemName: "list.triangle")
                }
                #if os(iOS)
                .frame(width: 32, height: 32)
                .modifier(ButtonBorderer())
                #endif
                .popover(isPresented: $linked_components_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    LinkedComponentsView(linked_components: $tool_module.linked_components)
                    {
                        document_handler.document_update_tools()
                    }
                }
            }
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $tool_module.description)
                    .textFieldStyle(.plain)
            case 1:
                OperationCodesEditor(tool_operations: $tool_module.codes)
                {
                    document_handler.document_update_tools()
                }
            case 2:
                CodeEditorView(code_items: $tool_module.code_items, avaliable_templates_names: [
                    "Controller": ["Internal Tool Controller", "External Tool Controller"],
                    "Connector": ["Internal Tool Connector", "External Tool Connector"]
                ], model_name: tool_module.name)
                {
                    document_handler.document_update_tools()
                }
            case 3:
                ResourcesPackageView(resources_names: $tool_module.resources_names, main_scene_name: $tool_module.main_scene_name, nodes_names: $tool_module.nodes_names)
                {
                    document_handler.document_update_tools()
                }
            default:
                EmptyView()
            }
        }
        #if !os(visionOS)
        .background(.white)
        #endif
    }
}

#Preview
{
    ToolModuleDesigner(tool_module: .constant(ToolModule()))
        .environmentObject(StandardTemplateConstruct())
}
