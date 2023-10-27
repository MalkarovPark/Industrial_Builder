//
//  ChangerModuleEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 12.10.2023.
//

import SwiftUI
import IndustrialKit

struct ChangerModulesEditor: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var is_presented: Bool
    
    @State private var appeared = false
    @State private var add_module_view_presented = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Modules for Changer")
                .font(.title2)
            #if os(visionOS)
                .padding(24)
            #else
                .padding()
            #endif
            
            List
            {
                ForEach(base_stc.changer_modules.indices, id: \.self)
                { index in
                    ChangerModuleDisclosureItem(name: base_stc.changer_modules[index].name, code: $base_stc.changer_modules[index].code)
                }
                .onDelete
                { indexSet in
                    base_stc.changer_modules.remove(atOffsets: indexSet)
                }
                .listStyle(.automatic)
            }
            
            Divider()
            
            HStack(spacing: 0)
            {
                Spacer()
                
                Button("New Module")
                {
                    add_module_view_presented = true
                }
                .popover(isPresented: $add_module_view_presented)
                {
                    AddChangerModuleView(is_presented: $add_module_view_presented, modules_items: $base_stc.changer_modules)
                    #if os(iOS)
                        .presentationDetents([.height(96)])
                    #endif
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        #if os(macOS)
        .frame(minWidth: 320, maxWidth: 800, minHeight: 320, maxHeight: 480)
        #elseif os(visionOS)
        .frame(width: 512, height: 512)
        #endif
    }
}

struct ChangerModuleDisclosureItem: View
{
    var name: String
    
    @Binding var code: String
    
    @State private var expanded = false
    
    var body: some View
    {
        DisclosureGroup(name, isExpanded: $expanded)
        {
            TextEditor(text: $code)
                .modifier(TextFrame())
        }
    }
}

func modules_names(_ modules: [ChangerModule]) -> [String]
{
    var names = [String]()
    for module in modules
    {
        names.append(module.name)
    }
    
    return names
}

struct AddChangerModuleView: View
{
    @Binding var is_presented: Bool
    @Binding var modules_items: [ChangerModule]
    
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
                    
                    //modules_items.append(ChangerModule(name: new_module_name))
                    modules_items.append(ChangerModule(name: mismatched_name(name: new_module_name, names: modules_names(modules_items))))
                    
                    is_presented = false
                }
                .fixedSize()
                .keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
    }
}

#Preview
{
    ChangerModulesEditor(is_presented: .constant(true))
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    AddChangerModuleView(is_presented: .constant(true), modules_items: .constant([ChangerModule]()))
        .environmentObject(StandardTemplateConstruct())
}
