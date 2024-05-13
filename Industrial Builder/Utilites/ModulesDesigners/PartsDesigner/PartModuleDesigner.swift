//
//  PartsModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 23.04.2024.
//

import SwiftUI
import IndustrialKit

struct PartModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var part_module: PartModule
    
    @State private var resources_names_update = false
    
    var body: some View
    {
        List
        {
            Section("Description")
            {
                TextEditor(text: $part_module.description)
                    .modifier(TextFrame())
                    .frame(maxHeight: 256)
                #if !os(macOS)
                    .onChange(of: part_module.description)
                    { _, _ in
                        document_handler.document_update_parts()
                    }
                #endif
            }
            
            DisclosureGroup("Resources")
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
        }
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
    PartModuleDesigner(part_module: .constant(PartModule()))
        .environmentObject(StandardTemplateConstruct())
}
