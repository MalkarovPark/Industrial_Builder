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
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    public init
    (
        entity_names: Binding<[String]>,
        entity_file_name: String?,
        
        on_update: @escaping () -> Void
    )
    {
        self._entity_names = entity_names
        self.entity_file_name = entity_file_name
        
        self.on_update = on_update
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
                            TextField("Name", text: $entity_names[index])
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
