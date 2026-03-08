//
//  OperationCodesItem.swift
//  Industrial Builder
//
//  Created by Artem on 07.03.2026.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct OperationCodesItem: View
{
    @Binding var operations: [OperationCodeInfo]
    
    public var on_update: () -> Void
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
    
    @State private var new_code_value = 0
    
    public init
    (
        operations: Binding<[OperationCodeInfo]>,
        
        on_update: @escaping () -> Void
    )
    {
        self._operations = operations
        
        self.on_update = on_update
        
        new_code_value = avaliable_opcode_value
    }
    
    public var body: some View
    {
        InspectorItem(label: "Operations", is_expanded: true)
        {
            ZStack
            {
                ScrollView
                {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 6)
                    {
                        ForEach(operations)
                        { operation in
                            OperationCodeEditor(operation: operation, operations: operations)
                            {
                                on_update()
                            }
                            .contextMenu
                            {
                                Button(role: .destructive)
                                {
                                    delete_operation(at: operation)
                                }
                                label:
                                {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        Button
                        {
                            operations.append(OperationCodeInfo(value: avaliable_opcode_value))
                            on_update()
                        }
                        label:
                        {
                            Image(systemName: "plus")
                                .frame(width: 16, height: 16)
                        }
                        .frame(width: 28)
                        .buttonStyle(.bordered)
                    }
                    .padding(8)
                }
                .animation(.spring(), value: operations)
            }
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(minHeight: 80, maxHeight: 160)
        }
    }
    
    private func delete_operation(at operation: OperationCodeInfo)
    {
        operations.removeAll { $0.id == operation.id }
        on_update()
    }
    
    private var avaliable_opcode_value: Int
    {
        let existing_values = Set(operations.map { $0.value })
        var new_value = existing_values.min() ?? 0

        while existing_values.contains(new_value) { new_value += 1 }

        return new_value
    }
}

private struct OperationCodeEditor: View
{
    @ObservedObject var operation: OperationCodeInfo
    
    let operations: [OperationCodeInfo]
    
    let on_update: () -> ()
    
    @State private var editor_is_presented: Bool = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) public var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        Button
        {
            editor_is_presented = true
        }
        label:
        {
            HStack
            {
                if is_valid_symbol(operation.symbol_name)
                {
                    Image(systemName: operation.symbol_name)
                }
                
                if !operation.name.isEmpty
                {
                    Text(operation.name)
                        .lineLimit(1)
                }
                else
                {
                    Text("Nameless")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(operation.value)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .popover(isPresented: $editor_is_presented, arrowEdge: .leading)
        {
            VStack(spacing: 16)
            {
                #if os(iOS)
                if horizontal_size_class == .compact
                {
                    HStack
                    {
                        Text("Operation Code")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button
                        {
                            position_item_view_presented = false
                        }
                        label:
                        {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                        }
                        .buttonStyle(.plain)
                    }
                }
                #endif
                
                HStack
                {
                    let name = Binding(
                        get: { operation.name },
                        set:
                            { new_value in
                                operation.name = new_value
                                
                                on_update()
                            }
                    )
                    
                    Text("Name")
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    TextField("Name", text: name)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                HStack
                {
                    let value = Binding(
                        get: { operation.value },
                        set:
                            { new_value in
                                operation.value = avaliable_opcode_value(for: new_value, in: operations)
                                
                                on_update()
                            }
                    )
                    
                    Text("Value")
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    TextField("0", value: value, format: .number)
                    #if !os(macOS)
                        .keyboardType(.decimalPad)
                    #endif
                        .textFieldStyle(.roundedBorder)
                    
                    Stepper("Value", value: value)
                        .labelsHidden()
                }
                
                Divider()
                
                VStack(alignment: .leading)
                {
                    let description = Binding(
                        get: { operation.description },
                        set:
                            { new_value in
                                operation.description = new_value
                                
                                on_update()
                            }
                    )
                    
                    Text("Description")
                        .fontWeight(.light)
                    
                    TextEditor(text: description)
                        .multilineTextAlignment(.leading)
                        .textFieldStyle(.roundedBorder)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .frame(minHeight: 80)
                }
                
                Divider()
                
                HStack
                {
                    let symbol_name = Binding(
                        get: { operation.symbol_name },
                        set:
                            { new_value in
                                operation.symbol_name = new_value
                                
                                on_update()
                            }
                    )
                    
                    Text("Symbol")
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    TextField("Symbol", text: symbol_name)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .frame(minWidth: 160)
            .padding()
        }
    }
    
    func avaliable_opcode_value(for value: Int, in operations: [OperationCodeInfo]) -> Int
    {
        let existing_values = Set(operations.map { $0.value })
        
        guard existing_values.contains(value) else { return value }
        
        var new_value = existing_values.min() ?? 0

        while existing_values.contains(new_value) { new_value += 1 }

        return new_value
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
