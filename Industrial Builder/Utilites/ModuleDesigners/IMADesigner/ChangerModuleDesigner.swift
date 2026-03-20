//
//  ChangerModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 12.10.2023.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct ChangerModuleDesigner: View
{
    @ObservedObject var module: ChangerModule
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var registers: [Float] = [Float](repeating: 0, count: 256)
    
    @State private var inspector_presented = false
    
    @State private var registers_count_presented = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        ZStack
        {
            RegistersView(registers: $registers, colors: default_register_colors)
            
            FloatingView(alignment: .bottomTrailing)
            {
                ZStack
                {
                    ChangerModuleControl(module: module, registers: $registers)
                    {
                        document_handler.document_update_ima()
                    }
                }
                #if os(macOS) || os(iOS)
                .padding(.leading, 10)
                #else
                .padding(.leading, 16)
                #endif
            }
            .padding()
        }
        .onAppear
        {
            #if os(macOS) || os(visionOS)
            inspector_presented = true
            #else
            if horizontal_size_class != .compact { inspector_presented = true }
            #endif
        }
        .inspector(isPresented: $inspector_presented)
        {
            #if os(macOS) || os(visionOS)
            ChangerInspectorView(module: module)
            {
                document_handler.document_update_ima()
            }
            #else
            if horizontal_size_class != .compact
            {
                ChangerInspectorView(module: module)
                {
                    document_handler.document_update_ima()
                }
            }
            else
            {
                ChangerInspectorView(module: module)
                {
                    document_handler.document_update_ima()
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .modifier(SheetCaption(is_presented: $inspector_presented, label: "Part"/*object_type_name*/))
            }
            #endif
        }
        .toolbar
        {
            #if !os(visionOS)
            ToolbarSpacer()
            #endif
            
            ToolbarItemGroup(placement: .primaryAction)
            {
                Button(action: clear_registers)
                {
                    Label("Eraser", systemImage: "eraser")
                }
                
                Button(action: { registers_count_presented = true })
                {
                    Label("Registers Count", systemImage: "square.grid.2x2")
                }
                .popover(isPresented: $registers_count_presented, arrowEdge: default_popover_edge_inverted)
                {
                    RegistersCountView(is_presented: $registers_count_presented, registers: $registers)
                    #if os(iOS)
                    .presentationDetents([.height(96)])
                    #endif
                }
            }
            
            ToolbarItem(placement: .primaryAction)
            {
                ControlGroup
                {
                    Button(action: { inspector_presented.toggle() })
                    {
                        #if os(macOS)
                        Label("Inspector", systemImage: "sidebar.right")
                        #else
                        Image(systemName: horizontal_size_class != .compact ? "sidebar.right" : "inset.filled.bottomthird.rectangle.portrait")
                        #endif
                    }
                }
            }
        }
    }
    
    private func clear_registers()
    {
        registers = [Float](repeating: 0, count: registers.count)
    }
}

private struct RegistersCountView: View
{
    @Binding var is_presented: Bool
    @Binding var registers: [Float]
    
    var body: some View
    {
        let registers_count = Binding(
            get: { registers.count },
            set:
                { new_value in
                    registers = updated_registers(registers, new_value > 1 ? new_value : 1)
                }
        )
        
        HStack(spacing: 8)
        {
            Button(action: { registers = updated_registers(registers, Workspace.default_registers_count) })
            {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            #if os(macOS)
            .foregroundColor(Color.white)
            #else
            .padding(.leading, 4)
            #endif
            
            TextField("\(Workspace.default_registers_count)", value: registers_count, format: .number)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
                .frame(width: 64)
            #else
                .frame(width: 128)
            #endif
            
            Stepper("Count", value: registers_count, in: 1...1000000)
                .labelsHidden()
            #if os(iOS) || os(visionOS)
                .padding(.trailing, 8)
            #endif
        }
        .padding(10)
        .controlSize(.regular)
    }
    
    public func updated_registers(_ registers: [Float], _ new_count: Int) -> [Float]
    {
        if registers.count > 0
        {
            var updated_registers = [Float](repeating: 0, count: new_count)
            
            for (index, value) in registers.enumerated()
            {
                if index < updated_registers.count
                {
                    updated_registers[safe: index] = Float(value)
                }
                else
                {
                    break
                }
            }
            
            return updated_registers
        }
        else
        {
            return registers
        }
    }
}

#Preview
{
    ChangerModuleDesigner(module: ChangerModule())
        .environmentObject(StandardTemplateConstruct())
}
