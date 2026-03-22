//
//  ConnectionParametersItem.swift
//  Industrial Builder
//
//  Created by Artem on 15.11.2024.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct ConnectionParametersItem: View
{
    @Binding var parameters: [ConnectionParameter]
    
    public var on_update: () -> Void
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
    
    #if os(iOS)
    private let is_compact: Bool
    #endif
    
    @State private var new_code_value = 0
    
    #if os(macOS) || os(visionOS)
    public init
    (
        parameters: Binding<[ConnectionParameter]>,
        
        on_update: @escaping () -> Void
    )
    {
        self._parameters = parameters
        
        self.on_update = on_update
        
        //new_code_value = avaliable_opcode_value
    }
    #else
    public init
    (
        parameters: Binding<[ConnectionParameter]>,
        
        on_update: @escaping () -> Void,
        is_compact: Bool
    )
    {
        self._parameters = parameters
        
        self.on_update = on_update
        
        self.is_compact = is_compact
    }
    #endif
    
    public var body: some View
    {
        InspectorItem(label: "Connection Parameters", is_expanded: false)
        {
            ZStack
            {
                ScrollView
                {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 6)
                    {
                        ForEach(parameters)
                        { parameter in
                            #if os(macOS) || os(visionOS)
                            ConnectionParameterEditor(parameter: parameter, parameters: parameters)
                            {
                                on_update()
                            }
                            .contextMenu
                            {
                                Button(role: .destructive)
                                {
                                    delete_parameter(at: parameter)
                                }
                                label:
                                {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            #else
                            ConnectionParameterEditor(parameter: parameter, parameters: parameters, on_update: on_update, is_compact: is_compact)
                            .contextMenu
                            {
                                Button(role: .destructive)
                                {
                                    delete_parameter(at: parameter)
                                }
                                label:
                                {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            #endif
                        }
                        
                        Menu
                        {
                            Button("String", systemImage: "text.justify")
                            {
                                add_paramter(value: "String")
                            }
                            
                            Button("Int", systemImage: "number")
                            {
                                add_paramter(value: 0)
                            }
                            
                            Button("Float", systemImage: "percent")
                            {
                                add_paramter(value: Float(0.0))
                            }
                            
                            Button("Bool", systemImage: "switch.2")
                            {
                                add_paramter(value: false)
                            }
                        }
                        label:
                        {
                            Image(systemName: "plus")
                        }
                        #if os(macOS)
                        .frame(width: 48)
                        #else
                        .frame(width: 42)
                        #endif
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                    }
                    .padding(8)
                }
                .animation(.spring(), value: parameters)
            }
            .background(.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(minHeight: 80, maxHeight: 160)
        }
    }
    
    private func delete_parameter(at parameter: ConnectionParameter)
    {
        parameters.removeAll { $0.id == parameter.id }
        on_update()
    }
    
    private func add_paramter(value: Any)
    {
        let name = "Nameless"
        parameters.append(ConnectionParameter(name: unique_name(for: name, in: parameters.map { $0.name }), value: value))
        on_update()
    }
}

private struct ConnectionParameterEditor: View
{
    @ObservedObject var parameter: ConnectionParameter
    
    let parameters: [ConnectionParameter]
    
    let on_update: () -> ()
    
    #if os(iOS)
    let is_compact: Bool
    #endif
    
    @State private var editor_is_presented: Bool = false
    
    #if os(macOS) || os(visionOS)
    private let preffered_arrow_edge: Edge = .leading
    #else
    private let preffered_arrow_edge: Edge = .trailing
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
                if let symbol_name = symbol_name
                {
                    Image(systemName: symbol_name)
                }
                
                if !parameter.name.isEmpty
                {
                    Text(parameter.name)
                        .lineLimit(1)
                }
                else
                {
                    Text("Nameless")
                        .foregroundStyle(.secondary)
                }
                
                /*Spacer()
                
                Text("\(parameter.value)")
                    .foregroundStyle(.secondary)*/
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .popover(isPresented: $editor_is_presented, arrowEdge: preffered_arrow_edge)
        {
            VStack(spacing: 16)
            {
                #if os(iOS)
                if is_compact
                {
                    HStack
                    {
                        Text("Connection Parameter")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button
                        {
                            editor_is_presented = false
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
                        get: { parameter.name },
                        set:
                            { new_value in
                                parameter.name = unique_name(
                                    for: new_value,
                                    in: parameters
                                        .filter { $0.name != parameter.name }
                                        .map { $0.name }
                                )
                                
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
                
                ParameterViewAlt(parameter: parameter, on_update: on_update)
                
                Divider()
                
                HStack
                {
                    let data_type = Binding<String>(
                        get:
                            {
                                switch parameter.value
                                {
                                case is String: "String"
                                case is Int: "Int"
                                case is Float: "Float"
                                case is Bool: "Bool"
                                default: "Bool"
                                }
                            },
                        set:
                            { (newValue: String) in
                                switch newValue
                                {
                                case "String": parameter.value = ""
                                case "Int": parameter.value = 0
                                case "Float": parameter.value = Float(0.0)
                                case "Bool": parameter.value = false
                                default: parameter.value = false
                                }
                                
                                on_update()
                            }
                    )
                    
                    Text("Type")
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    Picker("Type", selection: data_type)
                    {
                        ForEach(["String", "Int", "Float", "Bool"], id: \.self)
                        {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                    .labelsHidden()
                }
                
                /*Divider()
                
                VStack(alignment: .leading)
                {
                    let description = Binding(
                        get: { parameter.description },
                        set:
                            { new_value in
                                parameter.description = new_value
                                
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
                }*/
                
                #if os(iOS)
                if is_compact
                {
                    Spacer()
                }
                #endif
            }
            #if os(macOS) || os(visionOS)
            .frame(minWidth: 160)
            #else
            .frame(minWidth: 240)
            .presentationDetents([.height(260)])
            #endif
            .padding()
        }
    }
    
    private var symbol_name: String?
    {
        switch parameter.value
        {
        case is String: "text.justify"
        case is Int: "number"
        case is Float: "percent"
        case is Bool: "switch.2"
        default: nil
        }
    }
}

private struct ParameterViewAlt: View
{
    @ObservedObject var parameter: ConnectionParameter
    
    var on_update: () -> Void
    
    public init(
        parameter: ConnectionParameter,
        
        on_update: @escaping () -> Void
    )
    {
        self.parameter = parameter
        
        self.on_update = on_update
    }
    
    public var body: some View
    {
        HStack
        {
            Text("Value")
                .fontWeight(.light)
            
            Spacer()
            
            switch parameter.value
            {
            case is String:
                TextField("String", text: Binding(
                    get: { parameter.value as? String ?? "" },
                    set: { new_value in
                        parameter.value = new_value
                        on_update()
                    }
                ))
                .multilineTextAlignment(.trailing)
                .labelsHidden()
            case is Int:
                HStack
                {
                    TextField("Int", value: Binding(
                        get: { parameter.value as? Int ?? 0 },
                        set: { new_value in
                            parameter.value = new_value
                            on_update()
                        }
                    ), format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()

                    Stepper("Int", value: Binding(
                        get: { parameter.value as? Int ?? 0 },
                        set: { new_value in
                            parameter.value = new_value
                            on_update()
                        }
                    ), in: -1_000_000_000...1_000_000_000)
                    .labelsHidden()
                    .padding(.leading, 8)
                }
            case is Float:
                HStack
                {
                    TextField("Float", value: Binding(
                        get: { parameter.value as? Float ?? 0 },
                        set: { new_value in
                            parameter.value = new_value
                            on_update()
                        }
                    ), format: .number.grouping(.never))
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()

                    Stepper("Float", value: Binding(
                        get: { parameter.value as? Float ?? 0 },
                        set: { new_value in
                            parameter.value = new_value
                            on_update()
                        }
                    ), in: (-Float.infinity)...Float.infinity)
                    .labelsHidden()
                    .padding(.leading, 8)
                }
            case is Bool:
                Toggle(isOn: Binding(
                    get: { parameter.value as? Bool ?? false },
                    set: { new_value in
                        parameter.value = new_value
                        on_update()
                    }
                ))
                {
                    Text("Bool")
                }
                .toggleStyle(.switch)
                #if os(iOS) || os(visionOS)
                .tint(.accentColor)
                #endif
                .labelsHidden()
            default:
                Text("Unknown Parameter")
            }
        }
        .frame(height: 32)
    }
}
