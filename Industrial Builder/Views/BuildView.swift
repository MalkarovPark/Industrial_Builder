//
//  BuildView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI

struct BuildView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var targets_palette_view_presented = false
    
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
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("List"))
                {
                    /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
                }
                .frame(maxWidth: .infinity)
                #if os(iOS)
                .modifier(ButtonBorderer())
                #endif
                
                Button(action: {})
                {
                    Image(systemName: "plus")
                        .frame(width: 32)
                }
                .buttonBorderShape(.circle)
                
                Button(action: {})
                {
                    Image(systemName: "minus")
                        .frame(width: 32)
                }
                .buttonBorderShape(.circle)
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
    BuildView()
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    BuildItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
    /*{
        print("Packages")
    }*/
}
