//
//  BuildView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit

struct BuildView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var document: STCDocument
    
    @State private var targets_palette_view_presented = false
    @State private var selected_name = String()
    @State private var new_panel_presented = false
    
    #if os(iOS)
    //MARK: Horizontal window size handler
    @Environment(\.horizontalSizeClass) private var horizontal_size_class
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                Picker(selection: $selected_name, label: Text("List"))
                {
                    ForEach (base_stc.package_info.build_modules_lists_names, id: \.self)
                    { name in
                        Text(name)
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(base_stc.package_info.build_modules_lists.count == 0)
                #if os(iOS)
                .modifier(ButtonBorderer())
                #endif
                
                Button(action: { new_panel_presented = true })
                {
                    Image(systemName: "plus")
                    #if os(macOS)
                        .frame(width: 16)
                    #else
                        .frame(width: 32)
                    #endif
                }
                .popover(isPresented: $new_panel_presented, arrowEdge: .top)
                {
                    AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                    { new_name in
                        add_modules_list(new_name)
                    }
                }
                
                Button(action: { delete_modules_list(selected_name) })
                {
                    Image(systemName: "minus")
                    #if os(macOS)
                        .frame(width: 16)
                    #else
                        .frame(width: 32)
                    #endif
                }
            }
            .padding(.bottom)
            
            List
            {
                DisclosureGroup("Robots")
                {
                    Menu("Select")
                    {
                        ForEach (base_stc.images_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                        
                        Divider()
                        
                        ForEach (base_stc.scenes_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    /*if part_module.additional_resources_names != nil
                    {
                        ForEach (part_module.additional_resources_names!.indices, id: \.self)
                        { index in
                            Text(part_module.additional_resources_names![index])
                        }
                        .onDelete(perform: delete_module_name)
                        //.modifier(DoubleModifier(update_toggle: $resources_names_update))
                    }*/
                }
                
                DisclosureGroup("Tools")
                {
                    Menu("Select")
                    {
                        ForEach (base_stc.images_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                        
                        Divider()
                        
                        ForEach (base_stc.scenes_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    /*if part_module.additional_resources_names != nil
                    {
                        ForEach (part_module.additional_resources_names!.indices, id: \.self)
                        { index in
                            Text(part_module.additional_resources_names![index])
                        }
                        .onDelete(perform: delete_module_name)
                        //.modifier(DoubleModifier(update_toggle: $resources_names_update))
                    }*/
                }
                
                DisclosureGroup("Parts")
                {
                    Menu("Select")
                    {
                        ForEach (base_stc.images_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                        
                        Divider()
                        
                        ForEach (base_stc.scenes_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    /*if part_module.additional_resources_names != nil
                    {
                        ForEach (part_module.additional_resources_names!.indices, id: \.self)
                        { index in
                            Text(part_module.additional_resources_names![index])
                        }
                        .onDelete(perform: delete_module_name)
                        //.modifier(DoubleModifier(update_toggle: $resources_names_update))
                    }*/
                }
                
                DisclosureGroup("Changers")
                {
                    Menu("Select")
                    {
                        ForEach (base_stc.images_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                        
                        Divider()
                        
                        ForEach (base_stc.scenes_files_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                add_module_name(name)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    /*if part_module.additional_resources_names != nil
                    {
                        ForEach (part_module.additional_resources_names!.indices, id: \.self)
                        { index in
                            Text(part_module.additional_resources_names![index])
                        }
                        .onDelete(perform: delete_module_name)
                        //.modifier(DoubleModifier(update_toggle: $resources_names_update))
                    }*/
                }
            }
            .modifier(ListBorderer())
            .padding(.bottom)
            
            #if !os(iOS)
            HStack(spacing: 0)
            {
                Button(action: {})
                {
                    BuildItemView(title: "Files", subtitle: "Export to separated module files", image: Image(systemName: "folder.fill"))
                }
                .padding(.trailing)
                
                Button(action: {})
                {
                    BuildItemView(title: "App", subtitle: "Make a project with internal files", image: Image(systemName: "cube.fill"))
                }
            }
            #else
            if horizontal_size_class != .compact
            {
                HStack(spacing: 0)
                {
                    Button(action: {})
                    {
                        BuildItemView(title: "Files", subtitle: "Export to separated module files", image: Image(systemName: "folder.fill"))
                    }
                    .modifier(ButtonBorderer())
                    .padding(.trailing)
                    
                    Button(action: {})
                    {
                        BuildItemView(title: "App", subtitle: "Make a project with internal files", image: Image(systemName: "cube.fill"))
                    }
                    .modifier(ButtonBorderer())
                }
            }
            else
            {
                VStack(spacing: 0)
                {
                    Button(action: {})
                    {
                        BuildItemView(title: "Files", subtitle: "Export to separated module files", image: Image(systemName: "folder.fill"))
                    }
                    .modifier(ButtonBorderer())
                    .padding(.bottom)
                    
                    Button(action: {})
                    {
                        BuildItemView(title: "App", subtitle: "Make a project with internal files", image: Image(systemName: "cube.fill"))
                    }
                    .modifier(ButtonBorderer())
                }
            }
            #endif
        }
        .padding()
        .onChange(of: base_stc.package_info.build_modules_lists)
        { _, new_value in
            document.package_info.build_modules_lists = new_value
        }
        .onAppear
        {
            if base_stc.package_info.build_modules_lists.count > 0
            {
                selected_name = base_stc.package_info.build_modules_lists_names.first ?? ""
            }
        }
    }
    
    private func add_modules_list(_ name: String)
    {
        base_stc.package_info.build_modules_lists.append(BuildModulesList(name: name))
        selected_name = base_stc.package_info.build_modules_lists_names.first ?? ""
    }
    
    private func delete_modules_list(_ name: String)
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return
        }
        
        base_stc.package_info.build_modules_lists.remove(at: index)
    }
    
    private func add_module_name(_ name: String)
    {
        /*if part_module.additional_resources_names == nil
        {
            part_module.additional_resources_names = [String]()
        }
        
        if resource_name_index(name) == -1
        {
            part_module.additional_resources_names?.append(name)
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }*/
    }
    
    private func delete_module_name(at offsets: IndexSet)
    {
        /*withAnimation
        {
            part_module.additional_resources_names!.remove(atOffsets: offsets)
            
            if part_module.additional_resources_names?.count == 0
            {
                part_module.additional_resources_names = nil
            }
            resources_names_update.toggle()
            document_handler.document_update_parts()
        }*/
    }
}

struct BuildItemView: View
{
    let title: String
    let subtitle: String
    let image: Image
    //let on_tap: (() -> ())
    
    var body: some View
    {
        HStack
        {
            ZStack
            {
                Rectangle()
                    .foregroundStyle(Color.accentColor)
                image
                    .scaledToFit()
                    .foregroundStyle(.white)
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading)
            {
                Text(title)
                
                Text(subtitle)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .padding(.trailing, 8)
        }
        #if os(iOS)
        .padding(10)
        #else
        .padding(.vertical, 8)
        #endif
        .frame(maxWidth: .infinity)
    }
}

#Preview
{
    BuildView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    BuildItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
    /*{
        print("Packages")
    }*/
}
