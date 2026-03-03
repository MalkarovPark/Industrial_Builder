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
    @ObservedObject var module: RobotModule
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var inspector_presented = false
    
    @State private var entity_selector_presented = false
    @State private var is_pan = false
    
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
                RobotModelView(entity: entity_file_item.entity, is_pan: $is_pan)
            }
            else
            {
                VStack
                {
                    Text("No Entity")
                        .font(.title2)
                    
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
                document_handler.document_update_robots()
            }
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            RobotInspectorView(module: module, entity_selector_presented: $entity_selector_presented)
            {
                document_handler.document_update_robots()
            }
            #else
            if horizontal_size_class != .compact
            {
                InspectorView(module: module)
                {
                    document_handler.document_update_robots()
                }
            }
            else
            {
                InspectorView(module: module)
                {
                    document_handler.document_update_robots()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .modifier(SheetCaption(is_presented: $inspector_presented, label: "Robot"/*object_type_name*/))
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
    RobotModuleDesigner(module: RobotModule())
        .environmentObject(StandardTemplateConstruct())
}
