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
    
    @Binding var document: STCDocument
    @Binding var is_presented: Bool
    
    //@State private var changer_modules: [ChangerModule] = []
    @State private var expanded = [Bool]()
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
                ForEach(expanded.indices, id: \.self)
                { index in
                    if base_stc.changer_modules.count == expanded.count
                    {
                        DisclosureGroup(base_stc.changer_modules[index].name, isExpanded: $expanded[index])
                        {
                            TextEditor(text: $base_stc.changer_modules[index].code)
                                .frame(minHeight: 64)
                            #if os(macOS)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .shadow(radius: 1)
                            #endif
                        }
                    }
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
        .frame(minWidth: 320, maxWidth: 800, minHeight: 240, maxHeight: 600)
        #elseif os(visionOS)
        .frame(width: 512, height: 512)
        #endif
        .onChange(of: base_stc.changer_modules)
        { _, new_value in
            document.changer_modules = new_value
            if new_value.count != expanded.count
            {
                expanded = [Bool](repeating: false, count: base_stc.changer_modules.count)
            }
        }
        .onAppear
        {
            expanded = [Bool](repeating: false, count: base_stc.changer_modules.count)
        }
    }
}

func module_names(_ modules: [ChangerModule]) -> [String]
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
                    modules_items.append(ChangerModule(name: mismatched_name(name: new_module_name, names: module_names(modules_items))))
                    
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
    ChangerModulesEditor(document: .constant(STCDocument()), is_presented: .constant(true))
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    AddChangerModuleView(is_presented: .constant(true), modules_items: .constant([ChangerModule]()))
        .environmentObject(StandardTemplateConstruct())
}
