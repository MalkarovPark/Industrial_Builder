//
//  ModuleSelector.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct ModuleSelector: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    public let on_update: () -> Void
    
    @State private var targets_palette_view_presented = false
    @State private var new_panel_presented = false
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    private let row_spacing: CGFloat = 32
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 72, maximum: .infinity), spacing: 16)]
    private let row_spacing: CGFloat = 32
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
                    VStack(alignment: .leading, spacing: row_spacing / 2)
                    {
                        Text("Robot")
                        #if os(macOS)
                            .font(.title2)
                        #else
                            .font(.system(size: 18))
                        #endif
                            .padding(.bottom, 2)
                        
                        LazyVGrid(columns: columns, spacing: row_spacing)
                        {
                            ForEach(stc.robot_modules.sorted { $0.name < $1.name })
                            { module in
                                ModuleSelectionCard(
                                    module: module,
                                    is_selected: is_module_selected(module),
                                    on_update: on_update
                                )
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                
                if stc.tool_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: row_spacing / 2)
                    {
                        Text("Tool")
                        #if os(macOS)
                            .font(.title2)
                        #else
                            .font(.system(size: 18))
                        #endif
                            .padding(.bottom, 2)
                        
                        LazyVGrid(columns: columns, spacing: row_spacing)
                        {
                            ForEach(stc.tool_modules.sorted { $0.name < $1.name })
                            { module in
                                ModuleSelectionCard(
                                    module: module,
                                    is_selected: is_module_selected(module),
                                    on_update: on_update
                                )
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                
                if stc.part_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: row_spacing / 2)
                    {
                        Text("Part")
                        #if os(macOS)
                            .font(.title2)
                        #else
                            .font(.system(size: 18))
                        #endif
                            .padding(.bottom, 2)
                        
                        LazyVGrid(columns: columns, spacing: row_spacing)
                        {
                            ForEach(stc.part_modules.sorted { $0.name < $1.name })
                            { module in
                                ModuleSelectionCard(
                                    module: module,
                                    is_selected: is_module_selected(module),
                                    on_update: on_update
                                )
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                
                if stc.changer_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: row_spacing / 2)
                    {
                        Text("Changer")
                        #if os(macOS)
                            .font(.title2)
                        #else
                            .font(.system(size: 18))
                        #endif
                            .padding(.bottom, 2)
                        
                        LazyVGrid(columns: columns, spacing: row_spacing)
                        {
                            ForEach(stc.changer_modules.sorted { $0.name < $1.name })
                            { module in
                                ModuleSelectionCard(
                                    module: module,
                                    is_selected: is_module_selected(module),
                                    on_update: on_update
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: Module names handling
    private func is_module_selected(_ module: IndustrialModule) -> Binding<Bool>
    {
        Binding(
            get:
                {
                    is_listed(module: module)
                },
            set:
            { is_selected in
                var names = get_module_names(for: module)
                if is_selected
                {
                    names.append(module.name)
                }
                else
                {
                    names.removeAll { $0 == module.name }
                }
                
                set_module_names(names, for: module)
            }
        )
    }
    
    private func is_listed(module: IndustrialModule) -> Bool
    {
        get_module_names(for: module).contains(module.name)
    }
    
    private func get_module_names(for module: IndustrialModule) -> [String]
    {
        let list = stc.package_info.build_modules_list
        switch module
        {
        case is RobotModule: return list.robot_module_names
        case is ToolModule: return list.tool_module_names
        case is PartModule: return list.part_module_names
        case is ChangerModule: return list.changer_module_names
        default: return []
        }
    }
    
    private func set_module_names(_ names: [String], for module: IndustrialModule)
    {
        switch module
        {
        case is RobotModule:
            stc.package_info.build_modules_list.robot_module_names = names
        case is ToolModule:
            stc.package_info.build_modules_list.tool_module_names = names
        case is PartModule:
            stc.package_info.build_modules_list.part_module_names = names
        case is ChangerModule:
            stc.package_info.build_modules_list.changer_module_names = names
        default:
            break
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

private struct ModuleSelectionCard: View
{
    @ObservedObject var module: IndustrialModule
    
    @Binding var is_selected: Bool
    
    public let on_update: () -> Void
    
    @State private var is_renaming = false
    @State private var preview_entity: Entity?
    @State private var symbol_name = String()
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var view_id = UUID()
    
    public init(
        module: IndustrialModule,
        is_selected: Binding<Bool>,
        
        on_update: @escaping () -> Void
    )
    {
        self.module = module
        self._is_selected = is_selected
        
        self.on_update = on_update
    }
    
    public var body: some View
    {
        Button
        {
            withAnimation(.easeInOut(duration: 0.1))
            {
                is_selected.toggle()
            }
            
            on_update()
        }
        label:
        {
            if preview_entity != nil
            {
                GlassBoxCard(
                    title: module.name,
                    entity: preview_entity,
                    vertical_repostion: true
                )
                {
                    if is_selected
                    {
                        ZStack(alignment: .bottomTrailing)
                        {
                            Rectangle()
                                .fill(.clear)
                            
                            ZStack
                            {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.primary)
                            }
                            #if os(macOS)
                            .frame(width: 30, height: 30)
                            #else
                            .frame(width: 36, height: 36)
                            #endif
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: 128, height: 128)
                .scaleEffect(0.6)
            }
            else
            {
                GlassBoxCard(
                    title: module.name,
                    symbol_name: symbol_name,
                    symbol_size: 48,
                    symbol_weight: .regular
                )
                {
                    if is_selected
                    {
                        ZStack(alignment: .bottomTrailing)
                        {
                            Rectangle()
                                .fill(.clear)
                            
                            ZStack
                            {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.primary)
                            }
                            #if os(macOS)
                            .frame(width: 30, height: 30)
                            #else
                            .frame(width: 36, height: 36)
                            #endif
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: 128, height: 128)
                .scaleEffect(0.6)
            }
        }
        .buttonStyle(.plain)
        .id(view_id)
        .frame(width: 64, height: 64)
        .onAppear
        {
            load_entity()
        }
        .onChange(of: base_stc.entities_loaded)
        {
            view_id = UUID()
            load_entity()
        }
        .onDisappear
        {
            preview_entity = nil
        }
    }
    
    private func load_entity()
    {
        switch module
        {
        case is RobotModule: symbol_name = "r.square"
        case is ToolModule: symbol_name = "hammer"
        case is PartModule: symbol_name = "shippingbox"
        case is ChangerModule: symbol_name = "wand.and.rays"
        default: break
        }
        
        guard let entity_file_name =
            (module as? RobotModule)?.entity_file_name ??
            (module as? ToolModule)?.entity_file_name ??
            (module as? PartModule)?.entity_file_name
        else { return }
        
        if let entity_file_item = base_stc.entity_items.first(where: { $0.name == entity_file_name })
        {
            preview_entity = entity_file_item.entity.clone(recursive: true)
        }
        else
        {
            preview_entity = nil
        }
    }
}

public var all_code_templates: [String] = [
    // Project
    "List",
    
    // Robot
    "ExternalRobotConnector",
    "ExternalRobotModuleDeclaration",
    "InternalRobotConnector",
    "InternalRobotModelController",
    "InternalRobotModuleDeclaration",
    "RobotModelController",
    
    // Tool
    "ExternalToolConnector",
    "ExternalToolModuleDeclaration",
    "InternalToolConnector",
    "InternalToolModelController",
    "InternalToolModuleDeclaration",
    "ToolModelController",
    
    // Part
    "InternalPartModuleDeclaration",
    
    // Changer
    "ChangerFunction",
    "ExternalChangerModuleDeclaration",
    "InternalChangerFunction",
    "InternalChangerModuleDeclaration"
]

#Preview
{
    ModuleSelector(stc: StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
        .padding()
}
