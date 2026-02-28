//
//  PartModulesDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 23.04.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct PartModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @ObservedObject var part_module: PartModule
    
    @State private var inspector_presented = false
    
    @State private var editor_selection = 0
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            EmptyView()
            
            /*switch editor_selection
            {
            case 0:
                TextEditor(text: $part_module.description)
                    .textFieldStyle(.plain)
            default:
                EmptyView()
                /*ResourcesPackageView(resources_names: $part_module.resources_names, main_scene_name: $part_module.main_scene_name)
                {
                    document_handler.document_update_parts()
                }*/
            }*/
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            InspectorView()//(object: base_workspace.selected_object ?? WorkspaceObject())
            #else
            if horizontal_size_class != .compact
            {
                InspectorView()//(object: base_workspace.selected_object ?? WorkspaceObject())
            }
            else
            {
                InspectorView()//(object: base_workspace.selected_object ?? WorkspaceObject())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .modifier(SheetCaption(is_presented: $inspector_presented, label: "Part"/*object_type_name*/))
            }
            #endif
        }
        .toolbar
        {
            #if !os(visionOS)
            ToolbarSpacer()
            #endif
            
            /*ToolbarItem
            {
                Picker(selection: $editor_selection, label: Text("Picker"))
                {
                    Text("Description").tag(0)
                    Text("Resources").tag(1)
                }
                #if os(macOS)
                .pickerStyle(.segmented)
                #endif
                .labelsHidden()
            }*/
            
            ToolbarItem(id: "Inspector", placement: .confirmationAction)
            {
                ControlGroup
                {
                    Button(action: { inspector_presented.toggle() })
                    {
                        #if os(macOS)
                        Label("Inspector", systemImage: "sidebar.right")
                        #else
                        Image(systemName: horizontal_size_class != .compact ? "sidebar.right" : "inset.filled.bottomthird.rectangle.portrait")
                        #endif
                    }
                }
            }
        }
    }
}

struct InspectorView: View
{
    var body: some View
    {
        Text("Inspector")
    }
}

#Preview
{
    PartModuleDesigner(part_module: PartModule())
        .environmentObject(StandardTemplateConstruct())
}
