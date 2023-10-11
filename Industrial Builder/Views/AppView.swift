//
//  AppView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 11.10.2023.
//

import SwiftUI
import IndustrialKit

struct AppView: View
{
    @Binding var document: STCDocument
    
    @State private var is_editors_presented = [false, false, false]
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                Text("Robotic Complex Workspace")
                    .font(.title2)
                    .padding()
                
                LazyVGrid(columns: columns, spacing: 24)
                {
                    FunctionCard(is_presented: $is_editors_presented[0], name: "Robot", image_name: "r.square.fill", color: .green)
                    {
                        ChangerModuleEditor(is_presented: $is_editors_presented[0])
                    }
                    
                    FunctionCard(is_presented: $is_editors_presented[1], name: "Tool", image_name: "hammer.fill", color: .teal)
                    {
                        ChangerModuleEditor(is_presented: $is_editors_presented[1])
                    }
                    
                    FunctionCard(is_presented: $is_editors_presented[2], name: "Changer", image_name: "wand.and.rays", color: .indigo)
                    {
                        ChangerModuleEditor(is_presented: $is_editors_presented[2])
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .modifier(WindowFramer())
    }
}

struct FunctionCard<Content: View>: View
{
    @Environment(\.openWindow) var openWindow
    
    @Binding var is_presented: Bool
    
    let name: String
    let image_name: String
    let color: Color
    
    let content: () -> Content
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .foregroundColor(color)
        }
        .frame(height: 128)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(radius: 8.0)
        .overlay(alignment: .topLeading)
        {
            Text(name)
                .fontWeight(.bold)
                .font(.system(.title, design: .rounded))
                .foregroundColor(.white)
                .padding()
        }
        .overlay(alignment: .bottomTrailing)
        {
            Image(systemName: image_name)
                .fontWeight(.bold)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .shadow(radius: 8)
                .padding()
        }
        .onTapGesture
        {
            is_presented = true
            //openWindow(id: "editor")
        }
        .sheet(isPresented: $is_presented, content: {
            content()
        })
        //.padding()
    }
}

struct ChangerModuleEditor: View
{
    @Binding var is_presented: Bool
    
    @State private var modules_items: [ModuleItem] = []
    @State private var add_function_view_presented = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Modules for Changer")
                .font(.title2)
                .padding()
            
            List
            {
                ForEach(modules_items.indices, id: \.self)
                { index in
                    DisclosureGroup(modules_items[index].name, isExpanded: $modules_items[index].is_expanded)
                    {
                        TextEditor(text: $modules_items[index].text)
                            .frame(minHeight: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .shadow(radius: 1)
                    }
                }
                .listStyle(.automatic)
            }
            
            Divider()
            
            HStack(spacing: 0)
            {
                Spacer()
                
                Button("New Module")
                {
                    add_function_view_presented = true
                }
                .popover(isPresented: $add_function_view_presented)
                {
                    AddModuleView(is_presented: $add_function_view_presented, modules_items: $modules_items)
                }
                .padding()
            }
        }
        .overlay(alignment: .topLeading)
        {
            Button(action: { is_presented.toggle() })
            {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        #if os(macOS)
        .frame(minWidth: 320, maxWidth: 800, minHeight: 240, maxHeight: 600)
        #endif
    }
}

struct ModuleItem: Identifiable, Codable
{
    var id = UUID()
    var is_expanded = false
    var name = ""
    var text = ""
}

func module_names(_ modules: [ModuleItem]) -> [String]
{
    var names = [String]()
    for module in modules
    {
        names.append(module.name)
    }
    
    return names
}

struct AddModuleView: View
{
    @Binding var is_presented: Bool
    @Binding var modules_items: [ModuleItem]
    
    @State var new_module_name = ""
    
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
                    
                    //modules_items.append(ModuleItem(name: new_module_name))
                    modules_items.append(ModuleItem(name: mismatched_name(name: new_module_name, names: module_names(modules_items))))
                    
                    is_presented = false
                }
                .fixedSize()
                .keyboardShortcut(.defaultAction)
            }
            .padding(12)
        }
    }
}

/*struct EditorView: View
{
    var body: some View
    {
        
    }
}*/

#Preview
{
    AppView(document: .constant(STCDocument()))
}

#Preview
{
    ChangerModuleEditor(is_presented: .constant(true))
}

#Preview
{
    AddModuleView(is_presented: .constant(true), modules_items: .constant([ModuleItem]()))
}
