//
//  ToolModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 11.05.2024.
//

import SwiftUI
import RealityKit

import IndustrialKit

struct ToolModuleDesigner: View
{
    @ObservedObject var module: ToolModule
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var inspector_presented = false
    
    @State private var entity_selector_presented = false
    @State private var is_pan = false
    
    @ObservedObject private var workspace = Workspace()
    @StateObject private var previewed_tool = Tool(
        name: "preview",
        entity: Entity()
    )
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        ZStack
        {
            if let entity_file_name = module.entity_file_name,
               let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
            {
                ToolModelView(entity: entity_file_item.entity, is_pan: $is_pan)
            }
            else
            {
                VStack
                {
                    Text("No Entity")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Button("Select...")
                    {
                        entity_selector_presented = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.spring(), value: module.entity_file_name != nil)
        .onAppear
        {
            #if os(macOS) || os(visionOS)
            inspector_presented = true
            #else
            if horizontal_size_class != .compact { inspector_presented = true }
            #endif
        }
        .sheet(isPresented: $entity_selector_presented)
        {
            EntitySelectorView(is_presented: $entity_selector_presented)
            { entity_file_name in
                module.entity_file_name = entity_file_name
                document_handler.document_update_tools()
            }
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            ToolInspectorView(
                module: module,
                entity_selector_presented: $entity_selector_presented,
                previewed_tool: previewed_tool
            )
            {
                document_handler.document_update_tools()
            }
            #else
            if horizontal_size_class != .compact
            {
                InspectorView(module: module)
                {
                    document_handler.document_update_tools()
                }
            }
            else
            {
                InspectorView(module: module)
                {
                    document_handler.document_update_tools()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .modifier(SheetCaption(is_presented: $inspector_presented, label: "Tool"/*object_type_name*/))
            }
            #endif
        }
        .toolbar
        {
            #if !os(visionOS)
            ToolbarSpacer()
            #endif
            
            ToolbarItem(placement: .confirmationAction)
            {
                Button(action: { is_pan.toggle() })
                {
                    Label("View", systemImage: is_pan ? "move.3d" : "rotate.3d")
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                        .animation(.easeInOut(duration: 0.3), value: is_pan)
                }
                .disabled(module.entity_file_name == nil)
            }
            
            ToolbarItem(placement: .confirmationAction)
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

#Preview
{
    ToolModuleDesigner(module: ToolModule())
        .environmentObject(StandardTemplateConstruct())
}
