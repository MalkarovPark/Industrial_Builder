//
//  RobotModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 26.06.2024.
//

import SwiftUI
import IndustrialKit
import RealityKit
import IndustrialKitUI

struct RobotModuleDesigner: View
{
    @ObservedObject var module: RobotModule
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var inspector_presented = false
    
    @State private var entity_selector_presented = false
    @State private var is_pan = false
    
    /*@State private var workspace = Workspace()
    @State private var previewed_robot = Robot(
        name: "preview",
        entity: Entity()//,
        //model_controller: ExternalRobotModelController()
    )*/
    
    @ObservedObject private var workspace = Workspace()
    @StateObject private var previewed_robot = Robot(
        name: "preview",
        entity: Entity()//,
        //model_controller: ExternalRobotModelController()
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
                RobotModelView(
                    entity: entity_file_item.entity,
                    
                    workspace: workspace,
                    previewed_robot: previewed_robot,
                    
                    is_pan: $is_pan
                )
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
                document_handler.document_update_robots()
            }
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            RobotInspectorView(
                module: module,
                entity_selector_presented: $entity_selector_presented,
                previewed_robot: previewed_robot
            )
            {
                document_handler.document_update_robots()
            }
            #else
            if horizontal_size_class != .compact
            {
                RobotInspectorView(
                    module: module,
                    entity_selector_presented: $entity_selector_presented,
                    previewed_robot: previewed_robot
                )
                {
                    document_handler.document_update_robots()
                }
            }
            else
            {
                RobotInspectorView(
                    module: module,
                    entity_selector_presented: $entity_selector_presented,
                    previewed_robot: previewed_robot
                )
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

// MARK: - Test
open class JSRobotController: RobotModelController, @unchecked Sendable
{
    private struct Pose: Codable { let x, y, z, r, p, w: Float }
    private struct EntityPose: Codable { let name: String; let position: Pose }
    
    public var js_environment = JSEnvironment()
    
    override open var entity_names: [String]
    {
        return external_entity_names
    }
    
    public var external_entity_names = [String]()
    
    override open func entity_positions(
        pointer_position: (x: Float, y: Float, z: Float, r: Float, p: Float, w: Float),
        origin_position: (x: Float, y: Float, z: Float, r: Float, p: Float, w: Float)
    ) throws -> [(name: String, position: (x: Float, y: Float, z: Float, r: Float, p: Float, w: Float))]
    {
        // Wrap 12 numbers in a single array for JS
        let args: [Any] = [[
            pointer_position.x, pointer_position.y, pointer_position.z,
            pointer_position.r, pointer_position.p, pointer_position.w,
            origin_position.x, origin_position.y, origin_position.z,
            origin_position.r, origin_position.p, origin_position.w
        ]]
        
        // Call JS function
        let resultString = try js_environment.call_js_func(name: "entity_positions", args: args)
        
        // Decode JSON returned from JS
        guard let data = resultString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([EntityPose].self, from: data)
        else { return [] }
        
        // Map decoded objects to tuple array
        return decoded.map { ($0.name, ($0.position.x, $0.position.y, $0.position.z, $0.position.r, $0.position.p, $0.position.w)) }
    }
}
