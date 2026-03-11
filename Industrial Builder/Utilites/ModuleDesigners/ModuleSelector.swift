//
//  ModuleSelector.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

struct ModuleSelector: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    public let on_update: () -> Void
    
    @State private var targets_palette_view_presented = false
    @State private var new_panel_presented = false
    
    #if os(macOS)
    let column_count: Int = 4
    let grid_spacing: CGFloat = 10
    #else
    let column_count: Int = 6
    let grid_spacing: CGFloat = 16
    #endif
    
    public init(
        stc: StandardTemplateConstruct,
        
        on_update: @escaping () -> Void = {}
    )
    {
        self.stc = stc
        
        self.on_update = on_update
    }
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                if stc.robot_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Robot")
                            .font(.title2)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (stc.robot_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "r.square", color: Color(hex: "13C5B5"),
                                    is_selected: is_module_selected(name: name, type: .robot),
                                    on_update: on_update
                                )
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if stc.tool_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Tool")
                            .font(.title2)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (stc.tool_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "hammer", color: Color(hex: "6CC0FF"),
                                    is_selected: is_module_selected(name: name, type: .tool),
                                    on_update: on_update
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if stc.part_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Part")
                            .font(.title2)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (stc.part_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "shippingbox", color: Color(hex: "6965F0"),
                                    is_selected: is_module_selected(name: name, type: .part),
                                    on_update: on_update
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if stc.changer_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Changer")
                            .font(.title2)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (stc.changer_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "wand.and.rays", color: Color(hex: "F350B3"),
                                    is_selected: is_module_selected(name: name, type: .changer),
                                    on_update: on_update
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        let list = stc.package_info.build_modules_list
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
            stc.package_info.build_modules_list.robot_modules_names = names
        case .tool:
            stc.package_info.build_modules_list.tool_modules_names = names
        case .part:
            stc.package_info.build_modules_list.part_modules_names = names
        case .changer:
            stc.package_info.build_modules_list.changer_modules_names = names
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
    
    public let on_update: () -> Void
    
    public init(
        name: String,
        image_name: String,
        color: Color,
        is_selected: Binding<Bool>,
        
        on_update: @escaping () -> Void
    )
    {
        self.name = name
        self.image_name = image_name
        self.color = color
        self._is_selected = is_selected
        
        self.on_update = on_update
    }
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .foregroundStyle(color)
                .overlay//(alignment: .trailing)
                {
                    Image(systemName: image_name)
                        .fontWeight(.bold)
                        //.font(.system(size: 32))
                        .font(.system(size: 48))
                        .foregroundStyle(.quaternary.opacity(0.5))
                        .padding()
                    #if os(macOS)
                        .offset(x: -20, y: 20)
                    #else
                        .offset(x: -25, y: 25)
                    #endif
                }
                .overlay(alignment: .topLeading)
                {
                    VStack(spacing: 0)
                    {
                        Text(name)
                        #if os(macOS)
                            .font(.system(size: 12))
                        #else
                            .font(.system(size: 16))
                        #endif
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: color.opacity(0.2), radius: is_selected ? 8 : 0)
        }
        .overlay(alignment: .bottomTrailing)
        {
            if is_selected
            {
                ZStack
                {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.primary)
                }
                #if os(macOS)
                .frame(width: 20, height: 20)
                #else
                .frame(width: 24, height: 24)
                #endif
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(6)
            }
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
            on_update()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .aspectRatio(1, contentMode: .fit)
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

public var all_code_templates: [String] = [
    "List",
    "Internal 6DOF Controller",
    "Internal Portal Controller",
    "External Robot Connector",
    "External Robot Controller",
    "Internal Robot Connector",
    "Internal Robot Controller",
    "Robot Module",
    "External Tool Connector",
    "External Tool Controller",
    "Internal Tool Connector",
    "Internal Tool Controller",
    "Tool Module",
    "Part Module",
    "External Change",
    "Internal Change",
    "Changer Module"
]

public var external_app_code_templates: [String] = [
    "External Robot Connector",
    "External Robot Controller",
    "External Tool Connector",
    "External Tool Controller",
    "External Change"
]

#Preview
{
    ModuleSelector(stc: StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
        .padding()
}
