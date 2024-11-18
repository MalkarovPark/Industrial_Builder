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
    
    @State private var external_export_panel_presented = false
    @State private var internal_export_panel_presented = false
    
    #if os(iOS)
    //MARK: Horizontal window size handler
    @Environment(\.horizontalSizeClass) private var horizontal_size_class
    #endif
    
    @State private var is_compact = false
    
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
                
                Button("-")
                {
                    delete_modules_list(selected_name)
                }
                
                Button("+")
                {
                    new_panel_presented = true
                }
                .popover(isPresented: $new_panel_presented, arrowEdge: .top)
                {
                    AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                    { new_name in
                        add_modules_list(new_name)
                    }
                }
            }
            .padding(.bottom)
            
            List
            {
                if selected_list_index != -1
                {
                    DisclosureGroup("Robot")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.robot_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.robot_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Tool")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.tool_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.tool_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Part")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.part_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.part_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names)
                            }
                        }
                    }
                    
                    DisclosureGroup("Changer")
                    {
                        Menu("Add Module")
                        {
                            ForEach (base_stc.changer_modules_names, id: \.self)
                            { name in
                                Button(name)
                                {
                                    add_module_name(name, names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .frame(maxWidth: .infinity)
                        .disabled(base_stc.changer_modules.count == 0)
                        
                        if base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names.count > 0
                        {
                            ForEach (base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names.indices, id: \.self)
                            { index in
                                Text(base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names[index])
                                    .contextMenu
                                {
                                    Button(role: .destructive)
                                    {
                                        delete_module_name(at: IndexSet(integer: index), names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete
                            { index_set in delete_module_name(at: index_set, names: &base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names)
                            }
                        }
                    }
                }
            }
            .modifier(ViewBorderer())
            //.frame(maxWidth: .infinity)
            .padding(.bottom)
            
            DynamicStack(content: {
                Button(action: { external_export_panel_presented = true })
                {
                    BuildItemView(title: "Files", subtitle: "Export to separated modules files", image: Image(systemName: "folder.fill"))
                }
                .padding(!is_compact ? .trailing : .bottom)
                .fileImporter(isPresented: $external_export_panel_presented,
                              allowedContentTypes: [.folder],
                              allowsMultipleSelection: false)
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            base_stc.build_external_modules(list: selected_list, to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
                Button(action: { internal_export_panel_presented = true })
                {
                    BuildItemView(title: "App", subtitle: "Make a project with internal modules", image: Image(systemName: "cube.fill"))
                }
                .fileImporter(isPresented: $internal_export_panel_presented,
                              allowedContentTypes: [.folder],
                              allowsMultipleSelection: false)
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            base_stc.build_application_project(list: selected_list, to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
            }, is_compact: $is_compact, spacing: 0)
            .background
            {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    HStack
                    {
                        
                    }
                    .onAppear
                    {
                        is_compact = width < 550
                    }
                    .onChange(of: width) { newWidth, _ in
                        is_compact = newWidth < 550
                    }
                }
            }
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
        .overlay
        {
            if base_stc.on_building_modules// || true
            {
                BuildProgressView()
            }
        }
    }
    
    //MARK: Module lists handling
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
    
    private var selected_list_index: Int
    {
        return base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name }) ?? -1
    }
    
    private var selected_list: BuildModulesList
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return BuildModulesList(name: "")
        }
        return base_stc.package_info.build_modules_lists[index]
    }
    
    //MARK: Module names handling
    private func add_module_name(_ name: String, names: inout [String])
    {
        guard let _ = names.firstIndex(where: { $0 == name })
        else
        {
            names.append(name)
            return
        }
    }
    
    private func delete_module_name(at offsets: IndexSet, names: inout [String])
    {
        withAnimation
        {
            names.remove(atOffsets: offsets)
        }
    }
    
    //MARK: Export handling
}

struct BuildProgressView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            
            VStack//(spacing: 0)
            {
                ProgressView(
                    value: base_stc.build_progress, total: base_stc.build_total,
                    label:
                        {
                            Text("Building modules...")
                        },
                    currentValueLabel:
                        {
                            Text(base_stc.build_info)
                        }
                )
                
                /*HStack(spacing: 0)
                {
                    Spacer()
                    
                    Button("Cancel")
                    {
                        
                    }
                }*/
            }
            .padding()
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(width: 192)
        }
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}


struct BuildItemView: View
{
    let title: String
    let subtitle: String
    let image: Image
    
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
        .frame(width: 256)
}

#Preview
{
    BuildItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
}
