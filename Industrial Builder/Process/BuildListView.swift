//
//  BuildListView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

struct BuildListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var selected_name: String
    
    @State private var targets_palette_view_presented = false
    @State private var new_panel_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 8)]
    
    var body: some View
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
            .modifier(PickerBorderer())
            #endif
            
            #if os(macOS)
            Button("-")
            {
                delete_modules_list(selected_name)
            }
            
            Button("+")
            {
                new_panel_presented = true
            }
            .popover(isPresented: $new_panel_presented, arrowEdge: default_popover_edge_inverted)
            {
                AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                { new_name in
                    add_modules_list(new_name)
                }
            }
            #else
            Button(action: {delete_modules_list(selected_name)})
            {
                Image(systemName: "minus")
            }
            .frame(width: 32, height: 32)
            #if os(visionOS)
            .padding(.trailing)
            #endif
            
            Button(action:{new_panel_presented = true})
            {
                Image(systemName: "plus")
            }
            .frame(width: 32, height: 32)
            .popover(isPresented: $new_panel_presented, arrowEdge: default_popover_edge_inverted)
            {
                AddNewView(is_presented: $new_panel_presented, names: base_stc.package_info.build_modules_lists_names)
                { new_name in
                    add_modules_list(new_name)
                }
            }
            #endif
        }
        .padding()
        
        ScrollView(.vertical)
        {
            if base_stc.robot_modules.count > 0
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Robot")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach (base_stc.robot_modules_names, id: \.self)
                        { name in
                            ModuleTileView(
                                name: name,
                                image_name: "r.square", color: .green,
                                is_selected: is_module_selected(name: name, type: .robot)
                            )
                        }
                    }
                }
                .padding(8)
            }
            
            if base_stc.tool_modules.count > 0
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Tool")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach (base_stc.tool_modules_names, id: \.self)
                        { name in
                            ModuleTileView(
                                name: name,
                                image_name: "hammer", color: .teal,
                                is_selected: is_module_selected(name: name, type: .tool)
                            )
                        }
                    }
                }
                .padding(8)
            }
            
            if base_stc.part_modules.count > 0
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Part")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach (base_stc.part_modules_names, id: \.self)
                        { name in
                            ModuleTileView(
                                name: name,
                                image_name: "shippingbox", color: .indigo,
                                is_selected: is_module_selected(name: name, type: .part)
                            )
                        }
                    }
                }
                .padding(8)
            }
            
            if base_stc.changer_modules.count > 0
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Changer")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach (base_stc.changer_modules_names, id: \.self)
                        { name in
                            ModuleTileView(
                                name: name,
                                image_name: "wand.and.rays", color: .pink,
                                is_selected: is_module_selected(name: name, type: .changer)
                            )
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: Module lists handling
    private func add_modules_list(_ name: String)
    {
        base_stc.package_info.build_modules_lists.append(BuildModulesList(name: name))
        selected_name = base_stc.package_info.build_modules_lists_names.last ?? ""
    }
    
    private func delete_modules_list(_ name: String)
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return
        }
        
        base_stc.package_info.build_modules_lists.remove(at: index)
        
        selected_name = base_stc.package_info.build_modules_lists_names.last ?? ""
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
    
    // MARK: Module names handling
    private func is_module_selected(name: String, type: ModuleType) -> Binding<Bool>
    {
        Binding(
            get:
                {
                    is_listed(name: name, type: type)
                },
            set:
            { is_selected in
                var names = get_module_names(for: type)
                if is_selected
                {
                    names.append(name)
                }
                else
                {
                    names.removeAll { $0 == name }
                }
                
                set_module_names(names, for: type)
            }
        )
    }
    
    private func is_listed(name: String, type: ModuleType) -> Bool
    {
        get_module_names(for: type).contains(name)
    }
    
    private func get_module_names(for type: ModuleType) -> [String]
    {
        guard selected_list_index > -1 else
        {
            return []
        }
        
        let list = base_stc.package_info.build_modules_lists[selected_list_index]
        switch type
        {
        case .robot:
            return list.robot_modules_names
        case .tool:
            return list.tool_modules_names
        case .part:
            return list.part_modules_names
        case .changer:
            return list.changer_modules_names
        }
    }
    
    private func set_module_names(_ names: [String], for type: ModuleType)
    {
        switch type
        {
        case .robot:
            base_stc.package_info.build_modules_lists[selected_list_index].robot_modules_names = names
        case .tool:
            base_stc.package_info.build_modules_lists[selected_list_index].tool_modules_names = names
        case .part:
            base_stc.package_info.build_modules_lists[selected_list_index].part_modules_names = names
        case .changer:
            base_stc.package_info.build_modules_lists[selected_list_index].changer_modules_names = names
        }
    }
    
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
}

struct ModuleTileView: View
{
    let name: String
    let image_name: String
    let color: Color
    
    @Binding var is_selected: Bool
    
    public init(name: String, image_name: String, color: Color, is_selected: Binding<Bool>)
    {
        self.name = name
        self.image_name = image_name
        self.color = color
        self._is_selected = is_selected
    }
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .frame(width: 60, height: 60)
                .foregroundStyle(color)
                .overlay(alignment: .trailing)
                {
                    Image(systemName: image_name)
                        .fontWeight(.bold)
                        .font(.system(size: 48))
                    #if os(macOS)
                        .foregroundColor(Color(NSColor.quaternaryLabelColor))
                    #else
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                    #endif
                        .padding()
                        .offset(x: 30, y: 20)
                }
                .overlay(alignment: .topLeading)
                {
                    VStack(spacing: 0)
                    {
                        Text(name)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(radius: is_selected ? 4 : 0)
        }
        .overlay
        {
            if is_selected
            {
                ZStack
                {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.primary)
                }
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .frame(width: 64, height: 64)
    }
}

private enum ModuleType: String, Equatable, CaseIterable
{
    case robot = "Robot"
    case tool = "Tool"
    case part = "Part"
    case changer = "Changer"
    
    var image_name: String
    {
        switch self
        {
        case .robot:
            return "r.square"
        case .tool:
            return "hammer"
        case .part:
            return "shippingbox"
        case .changer:
            return "wand.and.rays"
        }
    }
}

#Preview
{
    BuildListView(selected_name: .constant("UwU"))
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
        .padding()
}
