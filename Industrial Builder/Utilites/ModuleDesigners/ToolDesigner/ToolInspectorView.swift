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
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .frame(minHeight: 80, maxHeight: 160)
                }
                
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
                
                InspectorItem(label: "Code", is_expanded: false)
                {
                    VStack(alignment: .leading)
                    {
                        Text("Model Controller")
                            .font(.system(size: 13))
                        
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
                        
                        Text("Connector")
                            .font(.system(size: 13))
                        
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
                print("Failed to convert JS output to Data: \(json_string)")
                return nil
            }
            
            let state = try JSONDecoder().decode(DeviceOutputData.self, from: json_data)
            return state
        }
        catch
        {
            print("JS current_device_output error: \(error.localizedDescription)")
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
                print("Failed to convert JS output to Data: \(json_string)")
                return nil
            }
            
            let state = try JSONDecoder().decode(DeviceOutputData.self, from: json_data)
            return state
        }
        catch
        {
            print("JS initial_device_output error: \(error.localizedDescription)")
            return nil
        }
    }
}*/
