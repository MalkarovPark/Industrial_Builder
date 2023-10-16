//
//  ToolModulesEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 13.10.2023.
//

import SwiftUI
import IndustrialKit

struct ToolModulesEditor: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var document: STCDocument
    @Binding var is_presented: Bool
    
    @State private var add_tool_module_presented = false
    //@State private var selection = ToolModule()
    
    @State var modules = [String]()
    @State private var tab_selection = 0
    
    private let editor_tabs = ["Controller", "Connector"]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Modules for Tool")
                .font(.title2)
            #if os(visionOS)
                .padding(24)
            #else
                .padding()
            #endif
            
            HStack(spacing: 0)
            {
                VStack(spacing: 0)
                {
                    ZStack
                    {
                        if base_stc.tool_modules.count > 0
                        {
                            List(base_stc.tool_modules_names, id: \.self, selection: $base_stc.selected_tool_module_name)
                            { names in
                                Text(names)
                            }
                            .listStyle(.plain)
                            .contextMenu
                            {
                                Button(role: .destructive, action: remove_tool)
                                {
                                    Label("Delete", systemImage: "xmark")
                                }
                            }
                        }
                        else
                        {
                            Rectangle()
                                .foregroundColor(.white)
                            //Text("No Modules")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .overlay(alignment: .bottomTrailing)
                    {
                        Button(action: { add_tool_module_presented = true})
                        {
                            Label("Add", systemImage: "plus")
                        }
                        .popover(isPresented: $add_tool_module_presented)
                        {
                            AddToolModuleView(is_presented: $add_tool_module_presented, modules_items: $base_stc.tool_modules, modules_names: base_stc.tool_modules_names)
                        }
                        .padding()
                    }
                }
                .frame(width: 200)
                #if os(iOS)
                .background(.white)
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .shadow(radius: 1)
                .padding(.trailing)
                
                GroupBox
                {
                    VStack(spacing: 0)
                    {
                        if base_stc.selected_tool_module_name != nil
                        {
                            Picker("", selection: $tab_selection)
                            {
                                ForEach(0..<editor_tabs.count, id: \.self)
                                { index in
                                    Text(self.editor_tabs[index]).tag(index)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                            .padding()
                            
                            switch tab_selection
                            {
                            case 0:
                                ToolControllerEditor(controller: $base_stc.selected_tool_module.controller)
                            case 1:
                                ToolConnectorEditor(connector: $base_stc.selected_tool_module.connector)
                            default:
                                Text("None")
                            }
                        }
                        else
                        {
                            Text("No module selected")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                #if os(visionOS)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                #endif
            }
            .padding([.horizontal, .bottom])
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        .modifier(SheetFramer())
        .onChange(of: base_stc.tool_modules)
        { _, new_value in
            document.tool_modules = base_stc.tool_modules
        }
    }
    
    private func remove_tool()
    {
        base_stc.remove_selected_tool_module()
    }
}

struct AddToolModuleView: View
{
    @Binding var is_presented: Bool
    @Binding var modules_items: [ToolModule]
    var modules_names: [String]
    
    @State private var new_module_name = ""
    
    var body: some View
    {
        VStack
        {
            HStack(spacing: 12)
            {
                TextField("Name", text: $new_module_name)
                    .frame(minWidth: 128, maxWidth: 256)
                #if os(iOS) || os(visionOS)
                    .frame(idealWidth: 256)
                    .textFieldStyle(.roundedBorder)
                #endif
                
                Button("Add")
                {
                    if new_module_name == ""
                    {
                        new_module_name = "None"
                    }
                    
                    modules_items.append(ToolModule(name: mismatched_name(name: new_module_name, names: modules_names)))
                    
                    is_presented = false
                }
                .fixedSize()
                .keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
    }
}

struct ToolControllerEditor: View
{
    @Binding var controller: ToolControllerModule
    
    private let scene_elements = ["Connect", "Reset", "Other"]
    @State private var scene_elements_expanded = [false, false, false, false]
    
    var body: some View
    {
        List
        {
            Section("Scene Functions")
            {
                DisclosureGroup(scene_elements[0], isExpanded: $scene_elements_expanded[0])
                {
                    TextEditor(text: $controller.connect)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(scene_elements[1], isExpanded: $scene_elements_expanded[1])
                {
                    TextEditor(text: $controller.reset)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(scene_elements[2], isExpanded: $scene_elements_expanded[2])
                {
                    TextEditor(text: $controller.other)
                        .modifier(TextFrame())
                }
            }
            
            Section("Model")
            {
                DisclosureGroup
                {
                    ModelView()
                } label:
                {
                    Text("Preview")
                }
            }
            
            StatisticsListView(statistics: $controller.statistics)
        }
        #if os(macOS)
        .listStyle(.plain)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct ToolConnectorEditor: View
{
    @Binding var connector: ToolConnectorModule
    
    private let elements = ["Connect", "Perform", "Disconnect", "Other"]
    @State private var elements_expanded = [false, false, false, false]
    
    private let statistics_elements = ["Chart", "Clear Chart", "State", "Clear State", "Other"]
    @State private var statistics_elements_expanded = [false, false, false, false, false]
    
    var body: some View
    {
        List
        {
            Section("Functions")
            {
                DisclosureGroup(elements[0], isExpanded: $elements_expanded[0])
                {
                    TextEditor(text: $connector.connect)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(elements[1], isExpanded: $elements_expanded[1])
                {
                    TextEditor(text: $connector.perform)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(elements[2], isExpanded: $elements_expanded[2])
                {
                    TextEditor(text: $connector.disconnect)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(elements[3], isExpanded: $elements_expanded[3])
                {
                    TextEditor(text: $connector.other)
                        .modifier(TextFrame())
                }
            }
            
            Section("Connection Parameters")
            {
                
            }
            
            StatisticsListView(statistics: $connector.statistics)
        }
        #if os(macOS)
        .listStyle(.plain)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct StatisticsListView: View
{
    @Binding var statistics: StatisticsFunctionsData
    
    private let statistics_elements = ["Chart", "Clear Chart", "State", "Clear State", "Other"]
    @State private var statistics_elements_expanded = [false, false, false, false, false]
    
    var body: some View
    {
        Section("Statistics Functions")
        {
            DisclosureGroup(statistics_elements[0], isExpanded: $statistics_elements_expanded[0])
            {
                TextEditor(text: $statistics.chart_code)
                    .modifier(TextFrame())
            }
            
            DisclosureGroup(statistics_elements[1], isExpanded: $statistics_elements_expanded[1])
            {
                TextEditor(text: $statistics.chart_code_clear)
                    .modifier(TextFrame())
            }
            
            DisclosureGroup(statistics_elements[2], isExpanded: $statistics_elements_expanded[2])
            {
                TextEditor(text: $statistics.state_code)
                    .modifier(TextFrame())
            }
            
            DisclosureGroup(statistics_elements[3], isExpanded: $statistics_elements_expanded[3])
            {
                TextEditor(text: $statistics.state_code_clear)
                    .modifier(TextFrame())
            }
            
            DisclosureGroup(statistics_elements[4], isExpanded: $statistics_elements_expanded[4])
            {
                TextEditor(text: $statistics.other_code)
                    .modifier(TextFrame())
            }
        }
    }
}

#Preview
{
    ToolModulesEditor(document: .constant(STCDocument()), is_presented: .constant(true))
        .environmentObject(StandardTemplateConstruct())
}
