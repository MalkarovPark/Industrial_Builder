//
//  ConnectionParametersView.swift
//  Industrial Builder
//
//  Created by Artem on 15.11.2024.
//

import SwiftUI
import IndustrialKit

struct ConnectionParametersView: View
{
    @Binding var connection_parameters: [ConnectionParameter]
    
    @State private var new_parameter_name: String = String()
    
    var update_file_data: () -> Void
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            VStack(spacing: 0)
            {
                List
                {
                    if connection_parameters.count > 0
                    {
                        ForEach($connection_parameters.indices, id: \.self)
                        { index in
                            ConnectionParameterView(parameter: $connection_parameters[index], update_file_data: update_file_data)
                                .contextMenu
                            {
                                Button(role: .destructive)
                                {
                                    delete_items(at: IndexSet(integer: index))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: delete_items)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(ViewBorderer())
                .overlay(alignment: .center)
                {
                    if !(connection_parameters.count > 0)
                    {
                        Text("No connection parameters")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .controlSize(.regular)
            .padding(.bottom)
            
            HStack(spacing: 0)
            {
                TextField("Name", text: $new_parameter_name)
                    .frame(maxWidth: .infinity)
                    .textFieldStyle(.plain)
                    .padding(.trailing)
                
                Menu
                {
                    Button("String", systemImage: "text.justify")
                    {
                        add_item(value: "String")
                    }
                    
                    Button("Int", systemImage: "number")
                    {
                        add_item(value: 0)
                    }
                    
                    Button("Float", systemImage: "percent")
                    {
                        add_item(value: Float(0.0))
                    }
                    
                    Button("Bool", systemImage: "switch.2")
                    {
                        add_item(value: true)
                    }
                }
                label:
                {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(minWidth: 256, minHeight: 256)
    }
    
    private func add_item(value: Any)
    {
        var name = new_parameter_name
        if new_parameter_name.isEmpty
        {
            name = "Name"
        }
        
        connection_parameters.append(ConnectionParameter(name: mismatched_name(name: name, names: connection_parameters.map { $0.name }), value: value))
        
        update_file_data()
    }
    
    private func delete_items(at offsets: IndexSet)
    {
        connection_parameters.remove(atOffsets: offsets)
        update_file_data()
    }
}

#Preview
{
    ConnectionParametersView(connection_parameters: .constant([
        .init(name: "String", value: "Text"),
        .init(name: "Int", value: 8),
        .init(name: "Float", value: Float(6)),
        .init(name: "Bool", value: true)
    ]), update_file_data: {})
    .frame(width: 320)
}
