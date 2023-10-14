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
    @Binding var is_presented: Bool
    
    @State private var add_tool_module_presented = false
    @State private var selection: String?
    
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
                        if modules.count > 0
                        {
                            List(modules, id: \.self, selection: $selection)
                            { module in
                                Text(module)
                            }
                            .listStyle(.plain)
                        }
                        else
                        {
                            Rectangle()
                                .foregroundColor(.white)
                            Text("No modules")
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
                            AddToolModuleView(is_presented: $add_tool_module_presented, modules_items: $modules)
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
                            ToolControllerEditor()
                        case 1:
                            ToolConnectorEditor()
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
            .padding([.horizontal, .bottom])
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        .modifier(SheetFramer())
    }
}

struct AddToolModuleView: View
{
    @Binding var is_presented: Bool
    @Binding var modules_items: [String]
    
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
                    
                    //modules_items.append(ChangerModule(name: mismatched_name(name: new_module_name, names: module_names(modules_items))))
                    modules_items.append(String(mismatched_name(name: new_module_name, names: modules_items)))
                    
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
    private let scene_elements = ["Connect", "Reset", "Other"]
    @State private var scene_elements_expanded = [false, false, false, false]
    
    private let statistics_elements = ["Chart", "Clear Chart", "State", "Clear State", "Other"]
    @State private var statistics_elements_expanded = [false, false, false, false, false]
    
    var body: some View
    {
        List
        {
            Section("Scene Functions")
            {
                ForEach(scene_elements.indices, id: \.self) { index in
                    DisclosureGroup(scene_elements[index], isExpanded: $scene_elements_expanded[index])
                    {
                        TextEditor(text: .constant("22"))
                            .frame(minHeight: 64)
                        #if os(macOS)
                            .shadow(radius: 1)
                        #endif
                    }
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
            
            Section("Statistics Functions")
            {
                ForEach(statistics_elements.indices, id: \.self) { index in
                    DisclosureGroup(statistics_elements[index], isExpanded: $statistics_elements_expanded[index])
                    {
                        TextEditor(text: .constant("22"))
                            .frame(minHeight: 64)
                        #if os(macOS)
                            .shadow(radius: 1)
                        #endif
                    }
                }
            }
        }
        .listStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct ToolConnectorEditor: View
{
    private let elements = ["Connect", "Perform", "Disconnect", "Other"]
    @State private var elements_expanded = [false, false, false, false]
    
    var body: some View
    {
        List
        {
            Section("Functions")
            {
                ForEach(elements.indices, id: \.self) { index in
                    DisclosureGroup(elements[index], isExpanded: $elements_expanded[index])
                    {
                        TextEditor(text: .constant("22"))
                            .frame(minHeight: 64)
                        #if os(macOS)
                            .shadow(radius: 1)
                        #endif
                    }
                }
            }
            
            Section("Connection Parameters")
            {
                
            }
        }
        .listStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

#Preview
{
    ToolModulesEditor(is_presented: .constant(true))
}
