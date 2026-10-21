//
//  ToolInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import IndustrialKit
import RealityKit

struct ToolInspectorView: View
{
    @ObservedObject var module: ToolModule
    
    @Binding var entity_selector_presented: Bool
    
    @StateObject var previewed_tool: Tool
    
    public let on_update: () -> ()
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    @State private var entity_selector_entity: Entity = ModelEntity(
        mesh: .generateBox(size: 1),
        materials: [
            SimpleMaterial(
                color: UIColor.systemGray.withAlphaComponent(0.5),
                roughness: 1.0,
                isMetallic: false
            )
        ]
    )
    
    @State private var part_selector_entity: Entity = ModelEntity(
        mesh: .generateBox(size: 1),
        materials: [
            SimpleMaterial(
                color: UIColor.systemGreen.withAlphaComponent(0.5),
                roughness: 1.0,
                isMetallic: false
            )
        ]
    )
    
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
                
                TextField("None", text: name)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                
                DescriptionItem(module: module, on_update: on_update)
                
                #if os(macOS) || os(visionOS)
                OperationCodesItem(operations: $module.codes)
                {
                    on_update()
                    
                    previewed_tool.codes = module.codes
                }
                #else
                OperationCodesItem(operations: $module.codes, on_update: {
                    on_update()
                    
                    previewed_tool.codes = module.codes
                }, is_compact: horizontal_size_class == .compact)
                #endif
                
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
                
                LinkedEntitiesItem(
                    entity_names: $module.entity_names, entity_file_name: module.entity_file_name,
                    on_update:
                        {
                            on_update()
                            update_model_controller()
                        },
                    on_menu_item_hover:
                        { hovered, name in
                            update_entity_selector(hovered: hovered, target_entity_name: name)
                        },
                    on_name_item_focused:
                        { focused, name in
                            update_part_selector(focused: focused, target_entity_name: name)
                        }
                )
                
                #if os(macOS) || os(visionOS)
                ConnectionParametersItem(parameters: $module.connection_parameters, on_update: on_update)
                #else
                ConnectionParametersItem(parameters: $module.connection_parameters, on_update: on_update, is_compact: horizontal_size_class == .compact)
                #endif
                
                InspectorItem(label: "Sources", is_expanded: false)
                {
                    VStack(alignment: .leading)
                    {
                        Text("Model Controller (JS)")
                            .fontWeight(.light)
                        
                        CodeEditorPane(
                            label: "Model Controller Code",
                            code: module.model_controller_code,
                            avaliable_template_names: [
                                "ToolModelController"
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
                                "InternalToolConnector",
                                "ExternalToolConnector"
                            ]
                        )
                        { new_value in
                            on_update()
                            module.connector_code = new_value
                            update_model_controller()
                        }
                    }
                }
            }
        }
        .onAppear
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                update_model_controller()
                previewed_tool.codes = module.codes
            }
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
        let new_controller = ExternalToolModelController(
            entity_names: module.entity_names,
            code: module.model_controller_code
        )
        
        previewed_tool.model_controller = new_controller as ToolModelController
    }
    
    private func update_entity_selector(hovered: Bool, target_entity_name: String)
    {
        if hovered
        {
            update_selector_entity(&entity_selector_entity, model_entity: previewed_tool.model_entity, target_entity_name: target_entity_name)
        }
        else
        {
            entity_selector_entity.scale = .one
            entity_selector_entity.position = .zero
            entity_selector_entity.removeFromParent()
        }
    }
    
    private func update_part_selector(focused: Bool, target_entity_name: String)
    {
        if focused
        {
            update_selector_entity(&part_selector_entity, model_entity: previewed_tool.model_entity, target_entity_name: target_entity_name)
        }
        else
        {
            part_selector_entity.scale = .one
            part_selector_entity.position = .zero
            part_selector_entity.removeFromParent()
        }
    }
}

#Preview
{
    @Previewable @ObservedObject var module = ToolModule()
    
    @Previewable @State var entity_selector_presented = false
    
    ZStack
    {
        
    }
    .inspector(isPresented: .constant(true))
    {
        ToolInspectorView(
            module: module,
            entity_selector_presented: $entity_selector_presented,
            previewed_tool: Tool(),
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

// MARK: - Test
/*open class ExternalToolModelControllerU: ToolModelController, @unchecked Sendable
{
    // MARK: Init functions
    public init(
        entity_names: [String],
        
        code: String
    )
    {
        self.external_entity_names = entity_names
        
        self.js_environment.js_code = code
    }
    
    required public init()
    {
        //self.module_name = ""
        //self.package_url = URL(fileURLWithPath: "")
    }
    
    // MARK: Parameters import
    override open var entity_names: [String]
    {
        return external_entity_names
    }
    
    public var external_entity_names = [String]()
    
    // MARK: JS Code Handling
    private var js_environment = JSEnvironment()
    
    public func reset_js_context()
    {
        js_environment.reset_context()
    }
    
    public var code: String
    {
        get { js_environment.js_code }
        set { js_environment.js_code = newValue }
    }
    
    // MARK: Statistics
    open override var current_device_output: DeviceOutputData?
    {
        do
        {
            let json_string = try js_environment.call_js_func(
                name: "current_device_output"
            )
            
            guard let json_data = json_string.data(using: .utf8)
            else
            {
                //print("Failed to convert JS output to Data: \(json_string)")
                return nil
            }
            
            let state = try JSONDecoder().decode(DeviceOutputData.self, from: json_data)
            return state
        }
        catch
        {
            //print("JS current_device_output error: \(error.localizedDescription)")
            return nil
        }
    }

    open override var initial_device_output: DeviceOutputData?
    {
        do
        {
            let json_string = try js_environment.call_js_func(
                name: "initial_device_output"
            )
            
            guard let json_data = json_string.data(using: .utf8)
            else
            {
                //print("Failed to convert JS output to Data: \(json_string)")
                return nil
            }
            
            let state = try JSONDecoder().decode(DeviceOutputData.self, from: json_data)
            return state
        }
        catch
        {
            //print("JS initial_device_output error: \(error.localizedDescription)")
            return nil
        }
    }
}*/
