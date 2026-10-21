//
//  LinkedEntitiesItem.swift
//  Industrial Builder
//
//  Created by Artem on 07.03.2026.
//

import SwiftUI
import RealityKit

public struct LinkedEntitiesItem: View
{
    @Binding var entity_names: [String]
    
    public let entity_file_name: String?
    
    public var on_update: () -> Void
    
    public var on_menu_item_hover: (Bool, String) -> Void
    public var on_name_item_focused: (Bool, String) -> Void
    
    @FocusState private var focused_field: Int?
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    public init
    (
        entity_names: Binding<[String]>,
        entity_file_name: String?,
        
        on_update: @escaping () -> Void,
        
        on_menu_item_hover: @escaping (Bool, String) -> Void = { _, _ in },
        on_name_item_focused: @escaping (Bool, String) -> Void = { _, _ in }
    )
    {
        self._entity_names = entity_names
        self.entity_file_name = entity_file_name
        
        self.on_update = on_update
        
        self.on_menu_item_hover = on_menu_item_hover
        self.on_name_item_focused = on_name_item_focused
    }
    
    public var body: some View
    {
        InspectorItem(label: "Linked Entities", is_expanded: false)
        {
            VStack(spacing: 4)
            {
                ScrollViewReader
                { proxy in
                    List
                    {
                        ForEach(entity_names.indices, id: \.self)
                        { index in
                            let entity_name = Binding(
                                get: { entity_names[index] },
                                set:
                                    { new_value in
                                        entity_names[index] = new_value
                                        
                                        on_name_item_focused(true, entity_names[index])
                                        on_update()
                                    }
                            )
                            
                            TextField("Name", text: entity_name) //$entity_names[index])
                            {
                                on_update()
                            }
                            .contextMenu
                            {
                                Button(role: .destructive)
                                {
                                    delete_items(at: IndexSet(integer: index))
                                }
                                label:
                                {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(.vertical, 8)
                            .textFieldStyle(.plain)
                            #if os(visionOS)
                            .padding(.horizontal, -32)
                            #endif
                            .focused($focused_field, equals: index)
                            .onChange(of: focused_field)
                            { old_value, new_value in
                                if let index = new_value
                                {
                                    on_name_item_focused(true, entity_names[index])
                                } else if let index = old_value
                                {
                                    on_name_item_focused(false, entity_names[index])
                                }
                            }
                        }
                        .onDelete(perform: delete_items)
                        
                        HStack
                        {
                            Spacer()
                            
                            Button
                            {
                                entity_names.append(String())
                                on_update()
                            }
                            label:
                            {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                            
                            Menu
                            {
                                if nested_entity_names.count > 0
                                {
                                    ForEach(nested_entity_names, id: \.self)
                                    { name in
                                        Button(name)
                                        {
                                            entity_names.append(name)
                                            on_update()
                                        }
                                        .onHover
                                        { hovered in
                                            on_menu_item_hover(hovered, name)
                                        }
                                    }
                                }
                                else
                                {
                                    Text("None")
                                        .disabled(true)
                                }
                            }
                            label:
                            {
                                Image(systemName: "chevron.down")
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                        .id("new_linked_entity_menu")
                        #if os(visionOS)
                        .padding(.horizontal, -32)
                        #endif
                        .listRowInsets(.vertical, 8)
                    }
                    .listStyle(.plain)
                    .onChange(of: entity_names.count)
                    {
                        withAnimation
                        {
                            proxy.scrollTo("new_linked_entity_menu", anchor: .bottom)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(minHeight: 160)
        }
    }
    
    private func delete_items(at offsets: IndexSet)
    {
        entity_names.remove(atOffsets: offsets)
        on_update()
    }
    
    private func remove_all_items()
    {
        entity_names.removeAll()
        on_update()
    }
    
    var nested_entity_names: [String]
    {
        if let entity_file_name = entity_file_name,
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

func update_selector_entity(_ entity: inout Entity, model_entity: Entity?, target_entity_name: String)
{
    if let target_entity = model_entity?.child_entity(withName: target_entity_name, recursively: true) //previewed_robot.model_entity?.child_entity(withName: target_entity_name, recursively: true)
    {
        // Scale compensation
        var total_scale = SIMD3<Float>(repeating: 1)
        var current: Entity? = target_entity
        
        while let entity = current
        {
            total_scale *= entity.scale
            current = entity.parent
        }
        
        let epsilon: Float = 1e-6
        let compensation_factor = SIMD3<Float>(
            x: abs(total_scale.x) > epsilon ? 1 / total_scale.x : 1,
            y: abs(total_scale.y) > epsilon ? 1 / total_scale.y : 1,
            z: abs(total_scale.z) > epsilon ? 1 / total_scale.z : 1
        )
        
        // Bounds
        let bounds = target_entity.visualBounds(relativeTo: target_entity).extents / compensation_factor
        let center = target_entity.visualBounds(relativeTo: target_entity).center
        
        // Placement
        entity.scale = compensation_factor * bounds + 0.01 * compensation_factor
        target_entity.addChild(entity)
        entity.position = center
    }
    else
    {
        entity.scale = .one
        entity.position = .zero
        entity.removeFromParent()
    }
}

#Preview
{
    LinkedEntitiesItem(entity_names: .constant(["OwO", "UwU"]), entity_file_name: nil) {
        
    }
}
