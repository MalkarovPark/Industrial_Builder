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
    @Binding var tool_operations: [OperationCodeInfo]
    
    public var update_document_func: () -> ()
    
    @State private var new_code_value = 0
    @State private var new_code_name = ""
    @State private var new_code_symbol = "questionmark"
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 192, maximum: .infinity), spacing: 24)]
    
    public init(tool_operations: Binding<[OperationCodeInfo]>, update_document_func: @escaping () -> ())
    {
        _tool_operations = tool_operations
        self.update_document_func = update_document_func
    }
    
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
                        ToolOperationCard(item: $tool_operations[index], on_change: update_document_func)
                            .contextMenu
                            {
                                Button("Delete", systemImage: "trash", role: .destructive)
                                {
                                    delete_opcode(index: index)
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
                
                TextField("Image", text: $new_code_symbol)
                    .textFieldStyle(.roundedBorder)
                    //.frame(width: 96)
                    .padding(.leading)
                
                Button
                {
                    add_code()
                }
                label:
                {
                    HStack
                    {
                        Text("Add")
                        
                        #if !os(visionOS)
                        Divider()
                        #endif
                        
                        //Image(systemName: new_code_symbol)
                        if is_valid_symbol(new_code_symbol)
                        {
                            #if os(macOS)
                            Image(nsImage: NSImage(systemSymbolName: new_code_symbol, accessibilityDescription: nil) ?? NSImage())
                            #else
                            Image(systemName: new_code_symbol)
                            #endif
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(tool_operations.contains(where: { $0.value == new_code_value }))
                .padding()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear
        {
            set_minimal_opcode_value()
        }
    }
    
    private func set_minimal_opcode_value()
    {
        var new_code_value = 0
        
        while tool_operations.contains(where: { $0.value == new_code_value })
        {
            new_code_value += 1
        }
        
        self.new_code_value = new_code_value
    }
    
    private func add_code()
    {
        tool_operations.append(OperationCodeInfo(value: new_code_value, name: new_code_name, symbol: new_code_symbol))
        
        //new_code_value += 1
        set_minimal_opcode_value()
        
        update_document_func()
    }
    
    private func delete_opcode(index: Int)
    {
        withAnimation
        {
            tool_operations.remove(at: index)
        }
        
        set_minimal_opcode_value()
        
        update_document_func()
    }
    
    private func is_valid_symbol(_ symbol: String) -> Bool
    {
        #if os(macOS)
        return NSImage(systemSymbolName: symbol, accessibilityDescription: nil) != nil
        #else
        return UIImage(systemName: symbol) != nil
        #endif
    }
}

struct ToolOperationCard: View
{
    @Binding var item: OperationCodeInfo
    
    public var on_change: (() -> Void) = {}
    
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
                .onSubmit
                {
                    on_change()
                }
            
            Divider()
            
            Image(systemName: "\(item.symbol)")
                .frame(width: 48, height: 48)
            #if !os(visionOS)
                .background(.white)
            #endif
                .popover(isPresented: $is_presented, arrowEdge: default_popover_edge)
                {
                    TextField("Symbol", text: $item.symbol)
                        .frame(minWidth: 200)
                        .padding()
                        .onSubmit
                        {
                            on_change()
                        }
                }
                .onTapGesture
                {
                    is_presented = true
                }
        }
        .frame(height: 48)
        #if !os(visionOS)
        .background(.white)
        #else
        .glassBackgroundEffect()
        #endif
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
                    #if !os(visionOS)
                        .foregroundColor(.white)
                    #endif
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
    OperationCodesEditor(tool_operations: .constant([OperationCodeInfo(), OperationCodeInfo(), OperationCodeInfo()]), update_document_func: {})
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
