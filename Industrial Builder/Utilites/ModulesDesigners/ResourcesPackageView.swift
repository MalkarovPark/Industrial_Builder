//
//  ComponentsPackageView.swift
//  Industrial Builder
//
//  Created by Artem on 20.06.2024.
//

import SwiftUI
import IndustrialKit

struct ResourcesPackageView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var resources_names: [String]?
    @Binding var main_scene_name: String?
    
    @State private var resources_names_update = false
    
    //@State private var module = IndustrialModule()
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    
    var body: some View
    {
        ScrollView
        {
            /*if resources_names != nil
            {
                ForEach (resources_names!.indices, id: \.self)
                { index in
                    Text(resources_names![index])
                }
            }*/
            
            Spacer(minLength: 10)
            
            LazyVGrid(columns: columns, spacing: 24)
            {
                ForEach(base_stc.scenes.indices, id: \.self)
                { index in
                    SelectSceneCard(scene: base_stc.scenes[index], name: base_stc.scenes_files_names[index], is_selected: is_scene_selected(index: index), is_main: is_main_scene(index: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
            
            LazyVGrid(columns: columns, spacing: 24)
            {
                ForEach(base_stc.images.indices, id: \.self)
                { index in
                    SelectImageCard(image: base_stc.images[index], name: base_stc.images_files_names[index], is_selected: is_image_selected(index: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func is_image_selected(index: Int) -> Binding<Bool>
    {
        Binding<Bool>(
            get:
            {
                resources_names?.contains(base_stc.images_files_names[index]) ?? false
            },
            set:
            { is_selected in
                if is_selected
                {
                    add_resource_file_name(base_stc.images_files_names[index])
                }
                else
                {
                    delete_resource_file_name(base_stc.images_files_names[index])
                }
            }
        )
    }
    
    private func is_scene_selected(index: Int) -> Binding<Bool>
    {
        Binding<Bool>(
            get:
            {
                resources_names?.contains(base_stc.scenes_files_names[index]) ?? false
            },
            set:
            { is_selected in
                if is_selected
                {
                    add_resource_file_name(base_stc.scenes_files_names[index])
                }
                else
                {
                    delete_resource_file_name(base_stc.scenes_files_names[index])
                    
                    main_scene_name = nil
                }
            }
        )
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
    
    private func is_main_scene(index: Int) -> Binding<Bool>
    {
        Binding<Bool>(
            get:
            {
                main_state(base_stc.scenes_files_names[index])
            },
            set:
            { is_main in
                if is_main
                {
                    if !(resources_names?.contains(base_stc.scenes_files_names[index]) ?? false)
                    {
                        add_resource_file_name(base_stc.scenes_files_names[index])
                    }
                    
                    main_scene_name = base_stc.scenes_files_names[index]
                }
                else
                {
                    main_scene_name = nil
                }
            }
        )
    }
    
    private func resource_name_index(_ selected_name: String) -> Int
    {
        guard let names = resources_names else
        {
            return -1
        }
        
        return names.firstIndex(where: { $0 == selected_name }) ?? -1
    }
    
    private func main_state(_ name: String) -> Bool
    {
        guard let main_name = main_scene_name else
        {
            return false
        }
        
        if name == main_name
        {
            return true
        }
        else
        {
            return false
        }
    }
}

#Preview
{
    ResourcesPackageView(resources_names: .constant([String]()), main_scene_name: .constant(""))
        .environmentObject(StandardTemplateConstruct())
}
