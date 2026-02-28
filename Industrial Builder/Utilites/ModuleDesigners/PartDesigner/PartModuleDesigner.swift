//
//  PartModulesDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 23.04.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI
import RealityKit

struct PartModuleDesigner: View
{
    @ObservedObject var part_module: PartModule
    
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
            if let entity_file_name = part_module.entity_file_name,
               let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
            {
                ObjectView(entity: entity_file_item.entity, is_pan: $is_pan)
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
        .animation(.spring(), value: part_module.entity_file_name != nil)
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
                part_module.entity_file_name = entity_file_name
                document_handler.document_update_parts()
            }
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            InspectorView(part_module: part_module, entity_selector_presented: $entity_selector_presented)
            {
                document_handler.document_update_parts()
            }
            #else
            if horizontal_size_class != .compact
            {
                InspectorView(part_module: part_module)
                {
                    document_handler.document_update_parts()
                }
            }
            else
            {
                InspectorView(part_module: part_module)
                {
                    document_handler.document_update_parts()
                }
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
            
            ToolbarItem(id: "View", placement: .confirmationAction)
            {
                Button(action: { is_pan.toggle() })
                {
                    Label("View", systemImage: is_pan ? "move.3d" : "rotate.3d")
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                        .animation(.easeInOut(duration: 0.3), value: is_pan)
                }
            }
            
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

struct ObjectView: View
{
    let entity: Entity?
    
    @State private var preview_entity: Entity?
    
    //@State private var is_pan = false
    @Binding var is_pan: Bool
    @State private var scene_content: RealityViewCameraContent?
    @State private var scene_camera = PerspectiveCamera()
    
    @StateObject var workspace = Workspace()
    @StateObject var preview_part = Part(name: "preview", entity: Entity())
    
    var body: some View
    {
        ZStack
        {
            RealityView
            { content in
                scene_content = content
                scene_content?.camera = .virtual
                
                workspace.place_entity(to: content)
                workspace.add_part(preview_part)
                
                place_entity(entity)
            }
            .realityViewCameraControls(is_pan ? .pan : .orbit)
            .gesture(
                TapGesture()
                    .onEnded
                    {
                        workspace.focus(on: preview_part.model_entity)
                    }
            )
            
            //SpatialPendantView(controller: pendant_controller, workspace: workspace)
                //.padding(10)
        }
        .onChange(of: entity)
        { old_value, new_value in
            update_entity(new_value)
        }
        .onDisappear
        {
            workspace.delete_part(name: "preview")
            preview_entity = nil
        }
    }
    
    private func place_entity(_ new_entity: Entity?)
    {
        if let new_entity = new_entity?.clone(recursive: true)
        {
            preview_entity = new_entity
            preview_part.model_entity?.addChild(new_entity)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            workspace.focus(on: preview_part.model_entity)
        }
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        
        place_entity(new_entity)
    }
    
    /*var body: some View
    {
        RealityView
        { content in
            scene_content = content
            scene_content?.camera = .virtual
            
            place_entity()
        }
        .realityViewCameraControls(is_pan ? .pan : .orbit)
        .onDisappear
        {
            preview_entity?.removeFromParent()
            preview_entity = nil
        }
        .onChange(of: entity)
        { _, new_value in
            update_entity(new_value)
        }
    }
    
    private func place_entity()
    {
        // Duplicate entity
        if preview_entity == nil, let entity = entity
        {
            preview_entity = entity.clone(recursive: true)
        }
        
        if let preview_entity = preview_entity
        {
            scene_content?.add(preview_entity)
            
            // Camera reposition
            let bounds = preview_entity.visualBounds(relativeTo: nil).extents
            scene_camera.position = [0, bounds.y / 2, bounds.z * 2]
            scene_content?.add(scene_camera)
        }
    }
    
    private func update_entity(_ new_entity: Entity?)
    {
        preview_entity?.removeFromParent()
        preview_entity = nil
        
        guard let new_entity = new_entity else { return }
        
        scene_content?.add(new_entity)
        
        // Camera reposition
        let bounds = new_entity.visualBounds(relativeTo: nil).extents
        scene_camera.position = [0, bounds.y / 2, bounds.z * 2]
    }*/
}

private struct InspectorView: View
{
    @ObservedObject var part_module: PartModule
    
    @Binding var entity_selector_presented: Bool
    
    public let on_update: () -> ()
    
    @State private var description_expanded = true
    @State private var entity_expanded = true
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 0)
            {
                let name = Binding(
                    get: { part_module.name },
                    set:
                        { new_value in
                            part_module.name = new_value
                            
                            on_update()
                        }
                )
                
                TextField("None", text: name)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                
                Divider()
                
                DisclosureGroup(isExpanded: $description_expanded)
                {
                    let description = Binding(
                        get: { part_module.description },
                        set:
                            { new_value in
                                part_module.description = new_value
                                
                                on_update()
                            }
                    )
                    
                    TextEditor(text: description)
                        .multilineTextAlignment(.leading)
                        .textFieldStyle(.roundedBorder)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .frame(minHeight: 80)
                }
                label:
                {
                    Text("Description")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(10)
                
                Divider()
                
                DisclosureGroup(isExpanded: $entity_expanded)
                {
                    HStack
                    {
                        if let entity_file_name = part_module.entity_file_name
                        {
                            Text(entity_file_name)
                                .frame(maxWidth: .infinity)
                            
                            Button
                            {
                                part_module.entity_file_name = nil
                                on_update()
                            }
                            label:
                            {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        else
                        {
                            Text("None")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        
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
                }
                label:
                {
                    Text("Entity")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(10)
                
                Divider()
            }
        }
    }
}



#Preview
{
    PartModuleDesigner(part_module: PartModule())
        .environmentObject(StandardTemplateConstruct())
}
