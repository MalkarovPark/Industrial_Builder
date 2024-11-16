//
//  ComponentsPackageView.swift
//  Industrial Builder
//
//  Created by Artem on 20.06.2024.
//

import SwiftUI
import IndustrialKit
import SceneKit

struct ResourcesPackageView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var resources_names: [String]?
    @Binding var main_scene_name: String?
    
    @Binding var connected_nodes_names: [String]
    
    @State private var is_connect_view_enabled: Bool = true
    @State private var is_connect_view_presented: Bool = false
    
    let on_update: () -> ()
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    
    public init(resources_names: Binding<[String]?>, main_scene_name: Binding<String?>, nodes_names: Binding<[String]>, on_update: @escaping () -> Void)
    {
        self._resources_names = resources_names
        self._main_scene_name = main_scene_name
        
        self._connected_nodes_names = nodes_names
        
        self.on_update = on_update
    }
    
    public init(resources_names: Binding<[String]?>, main_scene_name: Binding<String?>, on_update: @escaping () -> Void)
    {
        self._resources_names = resources_names
        self._main_scene_name = main_scene_name
        
        self._connected_nodes_names = .constant([String]())
        self.is_connect_view_enabled = false
        
        self.on_update = on_update
    }
    
    var body: some View
    {
        ScrollView
        {
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
            
            if is_connect_view_enabled
            {
                HStack(spacing: 0)
                {
                    Spacer()
                    
                    Button("Connected Nodes")
                    {
                        is_connect_view_presented.toggle()
                    }
                    .padding(.trailing)
                    .buttonStyle(.link)
                    .popover(isPresented: $is_connect_view_presented, arrowEdge: .bottom)
                    {
                        ConnectedNodesView(names: $connected_nodes_names, nested_nodes_names: nested_names, on_update: on_update)
                    }
                }
            }
            
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
            on_update()
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
            
            on_update()
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
                
                on_update()
            }
        )
    }
    
    private var nested_names: [String]
    {
        if let main_scene_name = main_scene_name,
           let scene_index = base_stc.scenes_files_names.firstIndex(of: main_scene_name)
        {
            return get_nodes_names(from: base_stc.scenes[scene_index].rootNode)
        }
        
        return [String]()
        
        func get_nodes_names(from node: SCNNode) -> [String]
        {
            var names: [String] = []
            
            if let name = node.name
            {
                names.append(name)
            }
            
            for child in node.childNodes
            {
                names.append(contentsOf: get_nodes_names(from: child))
            }
            
            return names
        }
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

struct ConnectedNodesView: View
{
    @Binding var names: [String]
    
    let nested_nodes_names: [String]
    
    let on_update: () -> ()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView
            {
                List
                {
                    ForEach(names.indices, id: \.self)
                    { index in
                        TextField("Name", text: $names[index])
                        {
                            on_update()
                        }
                        .contextMenu
                        {
                            Button(role: .destructive)
                            {
                                delete_items(at: IndexSet(integer: index))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: delete_items)
                }
                .listStyle(.inset)
                .frame(minWidth: 128, minHeight: 160)
                .scrollContentBackground(.hidden)
            }
        }
        .overlay(alignment: .bottomTrailing)
        {
            Menu
            {
                ForEach(nested_nodes_names, id: \.self)
                { name in
                    Button(name)
                    {
                        names.append(name)
                        on_update()
                    }
                }
                
                Divider()
                
                Button("Without name")
                {
                    names.append("")
                    on_update()
                }
                
                Button("All")
                {
                    names.append(contentsOf: nested_nodes_names)
                    on_update()
                }
            }
            label:
            {
                Image(systemName: "plus")
                    .padding(4)
            }
            .buttonStyle(.plain)
            .background(Color.secondary.opacity(0.2))
            .clipShape(Circle())
            .padding(8)
        }
    }
    
    private func delete_items(at offsets: IndexSet)
    {
        names.remove(atOffsets: offsets)
        on_update()
    }
}

#Preview
{
    ResourcesPackageView(resources_names: .constant([String]()), main_scene_name: .constant(""), nodes_names: .constant(["Neelo", "Nala"]), on_update: {})
        .environmentObject(StandardTemplateConstruct())
}
