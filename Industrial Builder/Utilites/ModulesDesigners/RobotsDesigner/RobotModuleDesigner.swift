//
//  RobotModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 26.06.2024.
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
    
    @State private var origin_shift_view_presented: Bool = false
    @State private var connection_parameters_view_presented: Bool = false
    @State private var linked_components_view_presented: Bool = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            switch editor_selection
            {
            case 0:
                TextEditor(text: $robot_module.description)
                    .textFieldStyle(.plain)
            case 1:
                CodeEditorView(code_items: $robot_module.code_items, avaliable_templates_names: [
                    "Controller": ["Internal Robot Controller", "External Robot Controller"],
                    "Connector": ["Internal Robot Connector", "External Robot Connector"]
                ], model_name: robot_module.name)
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
        #if !os(visionOS)
        .background(.white)
        #endif
        .toolbar
        {
            ToolbarSpacer()
            
            ToolbarItem
            {
                Picker(selection: $editor_selection, label: Text("Picker"))
                {
                    Text("Description").tag(0)
                    Text("Code").tag(1)
                    Text("Resources").tag(2)
                }
                #if os(macOS)
                .pickerStyle(.segmented)
                #endif
                .labelsHidden()
            }
            
            ToolbarSpacer()
            
            ToolbarItem
            {
                Button(action: { connection_parameters_view_presented.toggle() })
                {
                    Label("Link Parameters", systemImage: "link")
                }
                .popover(isPresented: $connection_parameters_view_presented, arrowEdge: .top)
                {
                    ConnectionParametersView(connection_parameters: $robot_module.connection_parameters)
                    {
                        document_handler.document_update_robots()
                    }
                }
            }
            
            ToolbarItem
            {
                Button(action: { origin_shift_view_presented.toggle() })
                {
                    Label("Origin Shift", systemImage: "scale.3d")
                }
                .popover(isPresented: $origin_shift_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    VStack(spacing: 12)
                    {
                        Text("Origin Shift")
                            .padding(.bottom, 4)
                        
                        OriginShiftView(shift: $robot_module.origin_shift)
                        {
                            document_handler.document_update_robots()
                        }
                    }
                    .controlSize(.regular)
                    .frame(minWidth: 160)
                    .padding()
                }
            }
            
            ToolbarItem
            {
                Button(action: { linked_components_view_presented.toggle() })
                {
                    Label("Internal Components", systemImage: "list.triangle")
                }
                .popover(isPresented: $linked_components_view_presented, arrowEdge: default_popover_edge_inverted)
                {
                    LinkedComponentsView(linked_components: $robot_module.linked_components)
                    {
                        document_handler.document_update_robots()
                    }
                }
            }
        }
    }
}

#Preview
{
    RobotModuleDesigner(robot_module: .constant(RobotModule()))
}
