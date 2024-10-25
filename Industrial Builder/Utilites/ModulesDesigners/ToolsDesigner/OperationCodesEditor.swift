//
//  OperationCodesEditor.swift
//  Industrial Builder
//
//  Created by Artem on 05.07.2024.
//

import SwiftUI
import IndustrialKit

struct OperationCodesEditor: View
{
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var tool_operations: [OperationCodeInfo]
    
    @State private var new_code_value = 0
    @State private var new_code_name = ""
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 192, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical)
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(tool_operations.indices, id: \.self)
                    { index in
                        ToolOperationCard(item: $tool_operations[index])
                            .contextMenu
                            {
                                Button("Delete", systemImage: "trash", role: .destructive)
                                {
                                    tool_operations.remove(at: index)
                                }
                            }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(20)
            }
            
            Divider()
            
            HStack(spacing: 0)
            {
                HStack
                {
                    TextField("0", value: $new_code_value, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 48)
                    
                    Stepper("Value", value: $new_code_value, in: 0...1000)
                        .labelsHidden()
                }
                .padding(.leading)
                
                TextField("Name", text: $new_code_name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                
                Button("Add")
                {
                    tool_operations.append(OperationCodeInfo(value: new_code_value, name: new_code_name, symbol: "questionmark"))
                    new_code_value += 1
                }
                .keyboardShortcut(.defaultAction)
                .disabled(tool_operations.contains(where: { $0.value == new_code_value }))
                .padding()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: tool_operations)
        { oldValue, newValue in
            document_handler.document_update_tools()
        }
    }
}

struct ToolOperationCard: View
{
    @Binding var item: OperationCodeInfo
    
    @State private var is_presented = false
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            Text("\(item.value)")
                .font(.title2)
                .foregroundStyle(.tertiary)
                .padding()
            
            Divider()
            
            TextField("Name", text: $item.name)
                .padding()
                .textFieldStyle(.plain)
                .frame(minWidth: 128)
            
            Divider()
            
            Image(systemName: "\(item.symbol)")
                .frame(width: 48, height: 48)
                .background(.white)
                .popover(isPresented: $is_presented)
                {
                    TextField("Symbol", text: $item.symbol)
                        .frame(minWidth: 256)
                        .padding()
                }
                .onTapGesture
                {
                    is_presented = true
                }
        }
        .frame(height: 48)
        .background(.white)
        .modifier(ViewBorderer())
    }
}

struct ToolOperationView: View
{
    @Binding var item: OperationCodeInfo
    
    var body: some View
    {
        VStack
        {
            TextField("Name", text: $item.name)
            
            Divider()
            
            HStack
            {
                TextField("Symbol", text: $item.symbol)
                
                ZStack
                {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .shadow(radius: 1)
                    
                    Image(systemName: "\(item.symbol)")
                        .foregroundColor(.accentColor)
                        .listStyle(.plain)
                }
                .frame(width: 18, height: 18)
            }
            
            Divider()
            
            TextEditor(text: $item.info)
                .modifier(TextFrame())
        }
    }
}

#Preview
{
    OperationCodesEditor(tool_operations: .constant([OperationCodeInfo(), OperationCodeInfo(), OperationCodeInfo()]))
        .frame(width: 512)
}

#Preview
{
    ToolOperationCard(item: .constant(OperationCodeInfo(value: 5, name: "Nameless", symbol: "applelogo")))
        .padding()
}

#Preview
{
    ToolOperationView(item: .constant(OperationCodeInfo(value: 5, name: "Nameless", symbol: "applelogo")))
        .padding()
}
