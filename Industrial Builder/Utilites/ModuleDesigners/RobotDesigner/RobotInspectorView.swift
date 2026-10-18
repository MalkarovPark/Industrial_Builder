//
//  RobotInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import IndustrialKit
import RealityKit
import IndustrialKitUI

struct RobotInspectorView: View
{
    @StateObject var module: RobotModule
    
    @Binding var entity_selector_presented: Bool
    
    @StateObject var previewed_robot: Robot
    
    public let on_update: () -> ()
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
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
                
                let default_origin_position = Binding(
                    get: { module.default_origin_position },
                    set:
                        { new_value in
                            module.default_origin_position = new_value
                            previewed_robot.origin_position = new_value
                            
                            on_update()
                        }
                )
                
                /*let default_space_scale = Binding(
                    get: { module.default_space_scale },
                    set:
                        { new_value in
                            module.default_space_scale = new_value
                            
                            on_update()
                        }
                )*/
                
                TextField("None", text: name)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                
                DescriptionItem(module: module, on_update: on_update)
                
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
                
                LinkedEntitiesItem(entity_names: $module.entity_names, entity_file_name: module.entity_file_name)
                {
                    on_update()
                    update_model_controller()
                }
                
                #if os(macOS) || os(visionOS)
                ConnectionParametersItem(parameters: $module.connection_parameters, on_update: on_update)
                #else
                ConnectionParametersItem(parameters: $module.connection_parameters, on_update: on_update, is_compact: horizontal_size_class == .compact)
                #endif
                
                InspectorItem(label: "End Point Entity", is_expanded: false)
                {
                    Menu(module.end_entity_name.isEmpty ? "None" : module.end_entity_name)
                    {
                        if nested_entity_names.count > 0
                        {
                            ForEach(nested_entity_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    module.end_entity_name = name
                                    on_update()
                                }
                            }
                        }
                        else
                        {
                            Text("None")
                                .disabled(true)
                        }
                        
                        Divider()
                        
                        Button
                        {
                            module.end_entity_name = String()
                            on_update()
                        }
                        label:
                        {
                            Label("Clear", systemImage: "xmark")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    #if os(iOS)
                    .tint(.black)
                    #endif
                    .padding(.top, 5)
                }
                
                InspectorItem(label: "Sources", is_expanded: false)
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Model Controller (JS)")
                            .fontWeight(.light)
                        
                        CodeEditorPane(
                            label: "Model Controller Code",
                            code: module.model_controller_code,
                            avaliable_template_names: [
                                "RobotModelController"
                            ]
                        )
                        { new_value in
                            on_update()
                            module.model_controller_code = new_value
                            update_model_controller()
                        }
                        
                        Spacer(minLength: 16)
                        
                        Text("Connector (Swift)")
                            .fontWeight(.light)
                        
                        CodeEditorPane(
                            label: "Connector Code",
                            code: module.connector_code,
                            avaliable_template_names: [
                                "InternalRobotConnector",
                                "ExternalRobotConnector"
                            ]
                        )
                        { new_value in
                            on_update()
                            module.connector_code = new_value
                            update_model_controller()
                        }
                    }
                }
                
                InspectorItem(label: "Working Area Shift", is_expanded: false)
                {
                    let origin_shift = Binding(
                        get:
                            {
                                (x: module.origin_shift.x,
                                 y: module.origin_shift.y,
                                 z: module.origin_shift.z)
                            },
                        set:
                            { new_value in
                                module.origin_shift = (x: new_value.x, y: new_value.y, z: new_value.z)
                                previewed_robot.origin_shift = module.origin_shift
                                on_update()
                            }
                    )
                    
                    PositionView(location: origin_shift, with_steppers: true)
                }
                
                InspectorItem(label: "Working Area Position", is_expanded: false)
                {
                    PositionView(position: default_origin_position, with_steppers: true)
                }
            }
        }
        .onAppear
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                update_model_controller()
            }
            //update_model_controller()
        }
    }
    
    private var nested_entity_names: [String]
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
    
    private func update_model_controller()
    {
        let new_controller = ExternalRobotModelController(
            entity_names: module.entity_names,
            code: module.model_controller_code
        )
        
        previewed_robot.model_controller = new_controller as RobotModelController
        
        previewed_robot.origin_shift = module.origin_shift
        previewed_robot.origin_position = module.default_origin_position
        previewed_robot.update_model()
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
            entity_selector_presented: $entity_selector_presented,
            previewed_robot: Robot(),
            on_update: {}
        )
        #if os(macOS)
        .inspectorColumnWidth(300)
        #elseif os(iOS)
        .inspectorColumnWidth(400)
        #endif
    }
    .frame(height: 600)
}
