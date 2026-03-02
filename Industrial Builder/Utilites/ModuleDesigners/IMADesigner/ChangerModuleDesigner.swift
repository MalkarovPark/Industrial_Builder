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
                    ChangerModuleControl(module: module)
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
                InspectorView(changer_module: changer_module)
                {
                    document_handler.document_update_ima()
                }
            }
            else
            {
                InspectorView(changer_module: changer_module)
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
            
            ToolbarItemGroup(placement: .confirmationAction)
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
            
            ToolbarItem(placement: .confirmationAction)
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

public struct ChangerModuleControl: View
{
    @ObservedObject var module: ChangerModule
    
    public let on_update: () -> ()
    
    @State private var is_expanded = false
    @State private var is_central_pressed = false
    
    @Namespace private var pane_glass
    
    @State private var code_editor_presented = false
    
    public init(
        module: ChangerModule,
        on_update: @escaping () -> ()
    )
    {
        self.module = module
        self.on_update = on_update
    }
    
    public var body: some View
    {
        HStack(spacing: 0)
        {
            GlassEffectContainer
            {
                if !is_expanded
                {
                    // Element Pane
                    HStack(spacing: 0)
                    {
                        VStack(alignment: .leading)
                        {
                            Text("Modifier")
                                .font(.title3.scaled(by: 0.8))
                                .lineLimit(1)
                            Text("Changer – \(module.name)")
                                .font(.default.scaled(by: 0.8))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(10)
                    }
                    .background(.clear)
                    .frame(width: 120)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16, style: .continuous))
                    .matchedGeometryEffect(id: "glass", in: pane_glass)
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .scaleEffect(is_central_pressed ? 0.95 : 1)
                    .animation(
                        .interactiveSpring(response: 0.35, dampingFraction: 0.6, blendDuration: 0),
                        value: is_central_pressed
                    )
                    .onTapGesture
                    {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
                        {
                            is_central_pressed = true
                            is_expanded = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                            {
                                is_central_pressed = false
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 1.0)))
                    .help("Info")
                }
                else
                {
                    // Editor
                    let code = Binding(
                        get: { module.changer_function_code },
                        set:
                            { new_value in
                                module.changer_function_code = new_value
                                
                                on_update()
                            }
                    )
                    
                    VStack(spacing: 0)
                    {
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                is_expanded = false
                            }
                        })
                        {
                            Image(systemName: "chevron.compact.down")
                            #if !os(macOS)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 16)
                            #endif
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                        .scaleEffect(is_expanded ? 1 : 0.01)
                        .contentShape(Rectangle())
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: is_expanded)
                        
                        ZStack
                        {
                            ZStack
                            {
                                CodeView(text: code, language: .javascript())
                            }
                            .background(.quinary)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .padding(10)
                    }
                    #if os(macOS)
                    .frame(height: is_expanded ? 280 : 120)
                    #else
                    .frame(height: is_expanded ? 320 : 120)
                    #endif
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16, style: .continuous))
                    .matchedGeometryEffect(id: "glass", in: pane_glass)
                    #if os(macOS) || os(iOS)
                    .padding(.vertical, 10)
                    #else
                    .padding(.vertical, 16)
                    #endif
                }
            }
            
            Button
            {
                //workspace.start_pause_single_element()
            }
            label:
            {
                ZStack
                {
                    Image(systemName: "wand.and.rays")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                        .frame(width: 48, height: 48)
                }
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            #if !os(visionOS)
            .glassEffect(.regular.interactive().tint(.pink), in: .rect(cornerRadius: 16, style: .continuous))
            #else
            .controlSize(.large)
            .buttonStyle(.borderless)
            .glassBackgroundEffect()
            .frame(depth: 24)
            #endif
            #if os(macOS) || os(iOS)
            .padding(10)
            #else
            .padding(16)
            #endif
        }
    }
}


#Preview
{
    ChangerModuleDesigner(module: ChangerModule())
        .environmentObject(StandardTemplateConstruct())
}
