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
    
    private var with_spacer = false
    
    //private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 8)]
    
    #if os(macOS)
    let column_count: Int = 4
    let grid_spacing: CGFloat = 10
    #else
    let column_count: Int = 6
    let grid_spacing: CGFloat = 16
    #endif
    
    public init(selected_name: Binding<String>)
    {
        self._selected_name = selected_name
    }
    
    public init(selected_name: Binding<String>, with_spacer: Bool = false)
    {
        self._selected_name = selected_name
        self.with_spacer = with_spacer
    }
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                if base_stc.robot_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Robot")
                            .font(.title3)
                        
                        LazyVGridU(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
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
                    .padding(.bottom, 16)
                }
                
                if base_stc.tool_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Tool")
                            .font(.title3)
                        
                        LazyVGridU(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (base_stc.tool_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "hammer", color: .teal,
                                    is_selected: is_module_selected(name: name, type: .tool)
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if base_stc.part_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Part")
                            .font(.title3)
                        
                        LazyVGridU(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (base_stc.part_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "shippingbox", color: .indigo,
                                    is_selected: is_module_selected(name: name, type: .part)
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if base_stc.changer_modules.count > 0
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Changer")
                            .font(.title3)
                        
                        LazyVGridU(columns: Array(repeating: .init(.flexible(), spacing: grid_spacing), count: column_count), spacing: grid_spacing)
                        {
                            ForEach (base_stc.changer_modules_names, id: \.self)
                            { name in
                                ModuleTileView(
                                    name: name,
                                    image_name: "wand.and.rays", color: .pink,
                                    is_selected: is_module_selected(name: name, type: .changer)
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                
                if with_spacer
                {
                    Spacer(minLength: 32)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: base_stc.package_info.build_modules_lists)
        { _, _ in
            document_handler.document_update_info()
        }
    }
    
    // MARK: Module lists handling
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
                    #if os(macOS)
                        .offset(x: 30, y: 20)
                    #else
                        .offset(x: 35, y: 25)
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
                #if os(macOS)
                .frame(width: 40, height: 40)
                #else
                .frame(width: 48, height: 48)
                #endif
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
    "Change External",
    "Change Internal",
    "Changer Module"
]

public var external_app_code_templates: [String] = [
    "External Robot Connector",
    "External Robot Controller",
    "External Tool Connector",
    "External Tool Controller",
    "Change External"
]

#Preview
{
    BuildListView(selected_name: .constant("UwU"))
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
        .padding()
}

// MARK: - Temporary replacement due to unknown crash on regular LazyVGrid.
struct LazyVGridU: Layout
{
    let columns: [GridItem]
    let spacing: CGFloat

    init(columns: [GridItem], spacing: CGFloat = 8)
    {
        self.columns = columns
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize
    {
        guard !columns.isEmpty else { return .zero }

        let columnCount = columns.count

        let totalWidth = proposal.width ?? 300

        var columnWidths = [CGFloat]()
        var flexibleColumnsCount = 0
        var fixedWidthSum: CGFloat = 0

        for column in columns
        {
            switch column.size
            {
            case .fixed(let width):
                columnWidths.append(width)
                fixedWidthSum += width
            case .flexible(let min, let max):
                flexibleColumnsCount += 1
                columnWidths.append(0)
            case .adaptive(let min, let max):
                flexibleColumnsCount += 1
                columnWidths.append(0)
            }
        }

        // Reposition remain width between columns
        let totalSpacing = CGFloat(columnCount - 1) * spacing
        let remainingWidth = max(0, totalWidth - fixedWidthSum - totalSpacing)
        let flexibleWidth = flexibleColumnsCount > 0 ? remainingWidth / CGFloat(flexibleColumnsCount) : 0

        for i in 0..<columnWidths.count
        {
            if columnWidths[i] == 0
            {
                // Adaptive width
                columnWidths[i] = flexibleWidth
            }
        }

        // Columns height
        var columnHeights = Array(repeating: CGFloat(0), count: columnCount)

        // Order cumns by index
        for (index, subview) in subviews.enumerated()
        {
            let col = index % columnCount
            // Column width
            let proposedSize = ProposedViewSize(width: columnWidths[col], height: nil)
            let size = subview.sizeThatFits(proposedSize)
            columnHeights[col] += size.height + spacing
        }

        let height = (columnHeights.max() ?? 0) - spacing // subtraction spacing

        return CGSize(width: totalWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ())
    {
        guard !columns.isEmpty else { return }

        let columnCount = columns.count
        let totalSpacing = CGFloat(columnCount - 1) * spacing
        let totalWidth = bounds.width

        // Like sizeThatFits — columns width calculation
        var columnWidths = [CGFloat]()
        var flexibleColumnsCount = 0
        var fixedWidthSum: CGFloat = 0

        for column in columns
        {
            switch column.size
            {
            case .fixed(let width):
                columnWidths.append(width)
                fixedWidthSum += width
            case .flexible(let min, let max):
                flexibleColumnsCount += 1
                columnWidths.append(0)
            case .adaptive(let min, let max):
                flexibleColumnsCount += 1
                columnWidths.append(0)
            }
        }

        let remainingWidth = max(0, totalWidth - fixedWidthSum - totalSpacing)
        let flexibleWidth = flexibleColumnsCount > 0 ? remainingWidth / CGFloat(flexibleColumnsCount) : 0

        for i in 0..<columnWidths.count
        {
            if columnWidths[i] == 0
            {
                columnWidths[i] = flexibleWidth
            }
        }

        // Columns Y
        var columnY = Array(repeating: bounds.minY, count: columnCount)

        // Place
        for (index, subview) in subviews.enumerated()
        {
            let col = index % columnCount
            let x = bounds.minX + columnWidths[..<col].reduce(0, +) + CGFloat(col) * spacing
            let y = columnY[col]

            let proposedSize = ProposedViewSize(width: columnWidths[col], height: nil)
            let size = subview.sizeThatFits(proposedSize)

            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: columnWidths[col], height: size.height))

            columnY[col] += size.height + spacing
        }
    }
}
