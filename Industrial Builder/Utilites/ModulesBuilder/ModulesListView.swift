//
//  ModulesListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 17.04.2024.
//

import SwiftUI
import IndustrialKit

struct ModulesListView: View
{
    @Binding var names: [String]
    @Binding var selected_name: String
    
    @State private var new_panel_presented = false
    @State private var new_name_presented = false
    
    private var add_module: (String) -> ()
    public var rename_module: (String) -> ()
    public var delete_module: () -> ()
    
    public init(names: Binding<[String]>, selected_name: Binding<String>, add_module: @escaping (String) -> Void, rename_module: @escaping (String) -> Void, delete_module: @escaping () -> Void)
    {
        self._names = names
        self._selected_name = selected_name
        
        self.add_module = add_module
        self.rename_module = rename_module
        self.delete_module = delete_module
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {
                if names.count > 0
                {
                    List(names, id: \.self, selection: $selected_name)
                    { names in
                        Text(names)
                    }
                    .popover(isPresented: $new_name_presented)
                    {
                        NewNameView(is_presented: $new_name_presented, names: names) { new_name in
                                rename_module(new_name)
                            }
                    }
                    .listStyle(.plain)
                    .contextMenu
                    {
                        RenameButton()
                            .renameAction
                        {
                            new_name_presented = true
                        }
                        
                        Button(role: .destructive, action: delete_module)
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
                Button(action: { new_panel_presented = true })
                {
                    Label("Add", systemImage: "plus")
                }
                .popover(isPresented: $new_panel_presented, arrowEdge: .top)
                {
                    AddNewView(is_presented: $new_panel_presented, names: names)
                    { new_name in
                        add_module(new_name)
                    }
                }
                .padding()
            }
        }
        .frame(width: 200)
        .modifier(ListBorderer())
        .padding(.trailing)
    }
}

struct NewNameView: View
{
    @Binding var is_presented: Bool
    
    @State var new_item_name = ""
    
    private var update_name: (String) -> Void
    private var names: [String]?
    
    public init(is_presented: Binding<Bool>, update_name: @escaping (String) -> Void)
    {
        self._is_presented = is_presented
        self.update_name = update_name
    }
    
    public init(is_presented: Binding<Bool>, names: [String], update_name: @escaping (String) -> Void)
    {
        self._is_presented = is_presented
        self.update_name = update_name
        self.names = names
    }
    
    public var body: some View
    {
        HStack(spacing: 0)
        {
            TextField("Name", text: $new_item_name)
                .padding(.trailing)
                .frame(minWidth: 96)
            
            Button("Update")
            {
                rename_perform()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }
    
    private func rename_perform()
    {
        if new_item_name == ""
        {
            new_item_name = "Name"
        }
        
        if names != nil
        {
            new_item_name = mismatched_name(name: new_item_name, names: names!)
        }
        
        update_name(new_item_name)
        is_presented = false
    }
}

#Preview
{
    ModulesListView(names: .constant([""]), selected_name: .constant(""), add_module: {_ in }, rename_module: {_ in }, delete_module: {})
}
