//
//  ToolsModuleView.swift
//  Industrial Builder
//
//  Created by Artem on 11.05.2024.
//

import SwiftUI
import IndustrialKit

struct ToolsModuleView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var tool_module: ToolModule
    
    @State private var resources_names_update = false
    @State private var tab_selection = 0
    
    private let editor_tabs = ["Codes", "Controller", "Connector"]
    
    var body: some View
    {
        GroupBox
        {
            VStack(spacing: 0)
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
                    ToolOperationCodesEditor(operation_codes: $tool_module.operation_codes)
                case 1:
                    ToolControllerEditor(controller: $tool_module.controller)
                case 2:
                    ToolConnectorEditor(connector: $tool_module.connector)
                default:
                    Text("None")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #if os(visionOS)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        #endif
    }
}

struct ToolOperationCodesEditor: View
{
    @Binding var operation_codes: [OperationCode]
    
    @State private var new_code_value = 0
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            List
            {
                ForEach(operation_codes.indices, id: \.self)
                { index in
                    OperationCodeDisclosureItem(operation_code: $operation_codes[index])
                }
                .onDelete
                { indexSet in
                    operation_codes.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)
            #if os(iOS)
            .background(.white)
            #endif
            
            Divider()
            
            HStack(spacing: 0)
            {
                TextField("0", value: $new_code_value, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                
                Stepper("Value", value: $new_code_value, in: 0...1000)
                    .labelsHidden()
                    .padding(.leading)
                
                Button("Add")
                {
                   if !operation_codes.contains(where: { $0.value == new_code_value })
                    {
                       operation_codes.append(OperationCode(value: new_code_value))
                       new_code_value += 1
                    }
                }
                .keyboardShortcut(.defaultAction)
                .padding()
            }
            .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OperationCodeDisclosureItem: View
{
    @Binding var operation_code: OperationCode
    
    @State private var expanded = false
    
    var body: some View
    {
        DisclosureGroup("\(operation_code.value)", isExpanded: $expanded)
        {
            OperationCodeItemView(element: $operation_code)
        }
    }
}

struct OperationCodeItemView: View
{
    @Binding var element: OperationCode
    
    @State private var tab_selection = 0
    
    private let editor_tabs = ["Controller", "Connector"]
    
    var body: some View
    {
        VStack
        {
            TextField("Name", text: $element.name)
            #if os(macOS)
                .textFieldStyle(.squareBorder)
            #endif
            HStack(spacing: 0)
            {
                TextField("Symbol", text: $element.symbol)
                #if os(macOS)
                    .textFieldStyle(.squareBorder)
                #endif
                Image(systemName: "\(element.symbol)")
                    .padding(.leading, 4)
            }
            
            Divider()
            
            Picker("", selection: $tab_selection)
            {
                ForEach(0..<editor_tabs.count, id: \.self)
                { index in
                    Text(self.editor_tabs[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(4)
            
            switch tab_selection
            {
            case 0:
                TextEditor(text: $element.controller_code)
                    .modifier(TextFrame())
            case 1:
                TextEditor(text: $element.connector_code)
                    .modifier(TextFrame())
            default:
                Text("None")
            }
        }
    }
}

struct ToolControllerEditor: View
{
    @Binding var controller: ToolControllerModule
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var scene_elements_expanded = [false, false, false, false]
    
    @State private var select_model_view_presented = false
    
    private let scene_elements = ["Connect", "Reset", "Other"]
    
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
            
            StatisticsListView(statistics: $controller.statistics)
            
            Section("Visual Model")
            {
                DisclosureGroup
                {
                    HStack(spacing: 0)
                    {
                        SceneView(node: $base_stc.viewed_model_node)
                            .frame(height: 240)
                        
                        Button(action: { select_model_view_presented.toggle() })
                        {
                            Image(systemName: "cube")
                                .imageScale(.large)
                                .frame(width: 8, height: 16)
                                .padding()
                            #if os(iOS)
                                .foregroundColor(false ? Color.secondary : Color.black)
                            #elseif os(visionOS)
                                .foregroundColor(false ? Color.secondary : Color.primary)
                            #endif
                        }
                        .popover(isPresented: $select_model_view_presented)
                        {
                            SceneSelectorView(is_presented: $select_model_view_presented, scenes: $base_stc.scenes)
                        }
                    }
                } label:
                {
                    Text("Preview")
                }
            }
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
    
    private let elements = ["Connect", "Disconnect", "Other"]
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
                    TextEditor(text: $connector.disconnect)
                        .modifier(TextFrame())
                }
                
                DisclosureGroup(elements[2], isExpanded: $elements_expanded[2])
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
    ToolsModuleView(tool_module: .constant(ToolModule()))
}
