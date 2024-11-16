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
                                    delete_item(at: IndexSet(integer: index))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: delete_item)
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
                    .textFieldStyle(.roundedBorder)
                    .padding(.trailing)
                
                MenuButton(label: Text("+"))
                {
                    Button("String")
                    {
                        add_item(value: "String")
                    }
                    Button("Int")
                    {
                        add_item(value: 0)
                    }
                    Button("Float")
                    {
                        add_item(value: Float(0.0))
                    }
                    Button("Bool")
                    {
                        add_item(value: true)
                    }
                }
                .frame(width: 42)
            }
        }
        .padding()
        .frame(minWidth: 256, minHeight: 256)
    }
    
    private func add_item(value: Any)
    {
        //connection_parameters.append(ConnectionParameter(name: new_parameter_name, value: value))
        //connection_parameters.append(ConnectionParameter(name: mismatched_name(name: new_parameter_name, names: connection_parameters.map { $0.name }), value: value))
        
        var name = new_parameter_name
        if new_parameter_name.isEmpty
        {
            name = "Name"
        }
        connection_parameters.append(ConnectionParameter(name: mismatched_name(name: name, names: connection_parameters.map { $0.name }), value: value))
        
        update_file_data()
    }
    
    private func delete_item(at offsets: IndexSet)
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
