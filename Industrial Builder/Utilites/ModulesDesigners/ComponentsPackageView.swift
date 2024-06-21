//
//  ComponentsPackageView.swift
//  Industrial Builder
//
//  Created by Artem on 20.06.2024.
//

import SwiftUI
import IndustrialKit

struct ComponentsPackageView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var resources_names_update = false
    
    @State private var part_module = PartModule()
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    
    var body: some View
    {
        List
        {
            Section("Scenes")
            {
                Menu("Add Resource")
                {
                    ForEach (base_stc.images_files_names, id: \.self)
                    { name in
                        Button(name)
                        {
                            add_resource_file_name(name)
                        }
                    }
                    
                    Divider()
                    
                    ForEach (base_stc.scenes_files_names, id: \.self)
                    { name in
                        Button(name)
                        {
                            add_resource_file_name(name)
                        }
                    }
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity)
                
                if part_module.additional_resources_names != nil
                {
                    ForEach (part_module.additional_resources_names!.indices, id: \.self)
                    { index in
                        Text(part_module.additional_resources_names![index])
                    }
                    .onDelete(perform: delete_resource_file_name)
                    .modifier(DoubleModifier(update_toggle: $resources_names_update))
                }
            }
            
            Section("Images")
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(base_stc.images.indices, id: \.self)
                    { index in
                        SelectImageCard(image: $base_stc.images[index], name: base_stc.images_files_names[index])
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func add_resource_file_name(_ name: String)
    {
        if part_module.additional_resources_names == nil
        {
            part_module.additional_resources_names = [String]()
        }
        
        if resource_name_index(name) == -1
        {
            part_module.additional_resources_names?.append(name)
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }
    }
    
    private func delete_resource_file_name(at offsets: IndexSet)
    {
        withAnimation
        {
            part_module.additional_resources_names!.remove(atOffsets: offsets)
            
            if part_module.additional_resources_names?.count == 0
            {
                part_module.additional_resources_names = nil
            }
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }
    }
    
    private func resource_name_index(_ selected_name: String) -> Int
    {
        guard let names = part_module.additional_resources_names
        else
        {
            return -1
        }
        return names.firstIndex(where: { $0 == selected_name }) ?? -1
    }
}

#Preview
{
    ComponentsPackageView()
        .environmentObject(StandardTemplateConstruct())
}
