//
//  ToolModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 11.05.2024.
//

import SwiftUI
import IndustrialKit

struct ToolModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var tool_module: ToolModule
    
    @State private var editor_selection = 0
    
    @State private var resources_names_update = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $editor_selection, label: Text("Picker"))
            {
                Text("Description").tag(0)
                Text("Code").tag(1)
                Text("Resources").tag(2)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $tool_module.description)
                    .textFieldStyle(.plain)
            case 1:
                CodeEditorView(code_items: $tool_module.code_items)
                {
                    document_handler.document_update_tools()
                }
            default:
                ResourcesPackageView(resources_names: $tool_module.resources_names, main_scene_name: $tool_module.main_scene_name)
                {
                    document_handler.document_update_tools()
                }
            }
        }
        .background(.white)
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

#Preview
{
    ToolModuleDesigner(tool_module: .constant(ToolModule()))
}
