//
//  RobotInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import IndustrialKit
import RealityKit

struct RobotInspectorView: View
{
    @ObservedObject var module: RobotModule
    
    @Binding var entity_selector_presented: Bool
    
    public let on_update: () -> ()
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var kinematic_code_editor_presented = false
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 0)
            {
                let name = Binding(
                    get: { module.name },
                    set:
                        { new_value in
                            module.name = new_value
                            
                            on_update()
                        }
                )
                
                let code = Binding(
                    get: { module.kinematic_function_code },
                    set:
                        { new_value in
                            module.kinematic_function_code = new_value
                            
                            on_update()
                        }
                )
                
                TextField("None", text: name)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                
                Divider()
                
                InspectorItem(label: "Description", is_expanded: true)
                {
                    let description = Binding(
                        get: { module.description },
                        set:
                            { new_value in
                                module.description = new_value
                                
                                on_update()
                            }
                    )
                    
                    TextEditor(text: description)
                        .multilineTextAlignment(.leading)
                        .textFieldStyle(.roundedBorder)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .frame(minHeight: 80)
                }
                
                InspectorItem(label: "Entity", is_expanded: true)
                {
                    HStack(spacing: 4)
                    {
                        if let entity_file_name = module.entity_file_name
                        {
                            Text(entity_file_name)
                                .frame(maxWidth: .infinity)
                            
                            Button
                            {
                                module.entity_file_name = nil
                                on_update()
                            }
                            label:
                            {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                            
                            Button
                            {
                                entity_selector_presented = true
                            }
                            label:
                            {
                                Image(systemName: "arrowshape.right.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        else
                        {
                            Text("None")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                InspectorItem(label: "Functions", is_expanded: true)
                {
                    ZStack
                    {
                        ZStack
                        {
                            ScrollView
                            {
                                if !module.kinematic_function_code.isEmpty
                                {
                                    Text(module.kinematic_function_code)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    #if os(macOS)
                                        .font(.custom("Menlo", size: 10))
                                    #else
                                        .font(.custom("Menlo", size: 14))
                                    #endif
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if module.kinematic_function_code.isEmpty
                            {
                                Text("No Code")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    #if os(macOS)
                                    .font(.system(size: 12))
                                    #else
                                    .font(.system(size: 16))
                                    #endif
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .background(.quinary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .frame(height: 120)
                        .overlay(alignment: .bottomTrailing)
                        {
                            Button
                            {
                                kinematic_code_editor_presented = true
                            }
                            label:
                            {
                                Image(systemName: "pencil")
                            }
                            .padding(10)
                        }
                    }
                    .sheet(isPresented: $kinematic_code_editor_presented)
                    {
                        CodeEditorView(is_presented: $kinematic_code_editor_presented, text: code, label: "Kinematic Function")
                    }
                }
                
                LinkedEntitiesItem(entity_names: $module.entity_names, entity_file_name: module.entity_file_name, on_update: on_update)
                
                InspectorItem(label: "End Point Entity", is_expanded: false)
                {
                    Menu(module.end_entity_name)
                    {
                        ForEach(nested_entities_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                module.end_entity_name = name
                                on_update()
                            }
                        }
                        
                        Divider()
                        
                        Button("Clear")
                        {
                            module.end_entity_name = String()
                            on_update()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    var nested_entities_names: [String]
    {
        if let entity_file_name = module.entity_file_name,
           let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
        {
            func collect(from entity: Entity) -> [String]
            {
                entity.children.flatMap
                { child in
                    [child.name] + collect(from: child)
                }
            }
            
            return collect(from: entity_file_item.entity)
        }
        else
        {
            return []
        }
    }
}

#Preview
{
    @Previewable @ObservedObject var module = RobotModule()
    
    @Previewable @State var entity_selector_presented = false
    
    ZStack
    {
        
    }
    .inspector(isPresented: .constant(true))
    {
        RobotInspectorView(
            module: module,
            entity_selector_presented: $entity_selector_presented)
            {
                
            }
    }
    .backgroundStyle(.windowBackground)
}
