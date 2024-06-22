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
    
    @Binding var resources_names: [String]?
    
    @State private var resources_names_update = false
    
    //@State private var module = IndustrialModule()
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    
    var body: some View
    {
        List
        {
            /*if resources_names != nil
            {
                ForEach (resources_names!.indices, id: \.self)
                { index in
                    Text(resources_names![index])
                }
            }*/
            
            Section("Scenes")
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(base_stc.scenes.indices, id: \.self)
                    { index in
                        SelectSceneCard(scene: $base_stc.scenes[index], name: base_stc.scenes_files_names[index], is_selected: resources_names?.contains(base_stc.scenes_files_names[index]) ?? false)
                        {
                            add_resource_file_name(base_stc.scenes_files_names[index])
                        }
                        on_deselect:
                        {
                            delete_resource_file_name(base_stc.scenes_files_names[index])
                        }
                    }
                }
                .padding(8)
                .padding(.vertical, 6)
            }
            
            Section("Images")
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(base_stc.images.indices, id: \.self)
                    { index in
                        SelectImageCard(image: $base_stc.images[index], name: base_stc.images_files_names[index], is_selected: resources_names?.contains(base_stc.images_files_names[index]) ?? false)
                        {
                            add_resource_file_name(base_stc.images_files_names[index])
                        }
                        on_deselect:
                        {
                            delete_resource_file_name(base_stc.images_files_names[index])
                        }
                    }
                }
                .padding(8)
                .padding(.vertical, 6)
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func add_resource_file_name(_ name: String)
    {
        if resources_names == nil
        {
            resources_names = [String]()
        }
        
        if resource_name_index(name) == -1
        {
            resources_names?.append(name)
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }
    }
    
    private func delete_resource_file_name(_ name: String)
    {
        withAnimation
        {
            resources_names!.remove(at: (resources_names?.firstIndex(of: name))!)
            
            if resources_names?.count == 0
            {
                resources_names = nil
            }
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }
    }
    
    private func resource_name_index(_ selected_name: String) -> Int
    {
        guard let names = resources_names
        else
        {
            return -1
        }
        return names.firstIndex(where: { $0 == selected_name }) ?? -1
    }
}

#Preview
{
    ComponentsPackageView(resources_names: .constant([String]()))
        .environmentObject(StandardTemplateConstruct())
}
