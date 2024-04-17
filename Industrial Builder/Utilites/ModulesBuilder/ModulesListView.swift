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
    
    private var add_module: (String) -> ()
    public var remove_module: () -> ()
    
    public init(names: Binding<[String]>, selected_name: Binding<String>, add_module: @escaping (String) -> Void, remove_module: @escaping () -> Void)
    {
        self._names = names
        self._selected_name = selected_name
        self.add_module = add_module
        self.remove_module = remove_module
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
                    .listStyle(.plain)
                    .contextMenu
                    {
                        Button(role: .destructive, action: remove_module)
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
                .popover(isPresented: $new_panel_presented, arrowEdge: .bottom)
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

#Preview
{
    ModulesListView(names: .constant([""]), selected_name: .constant(""), add_module: {_ in }, remove_module: {})
}
