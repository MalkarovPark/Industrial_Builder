//
//  ChangerModuleControl.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

public struct ChangerModuleControl: View
{
    @ObservedObject var module: ChangerModule
    
    @Binding var registers: [Float]
    
    public let on_update: () -> ()
    
    @State private var is_expanded = false
    @State private var is_central_pressed = false
    
    @Namespace private var pane_glass
    
    @State private var code_editor_presented = false
    @State private var new_code_view_presented = false
    
    @State private var process_error: Error?
    
    public init(
        module: ChangerModule,
        registers: Binding<[Float]>,
        on_update: @escaping () -> ()
    )
    {
        self.module = module
        self._registers = registers
        self.on_update = on_update
    }
    
    public var body: some View
    {
        HStack(spacing: 12)
        {
            ZStack
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
                                //.animation(.easeInOut(duration: 0.2), value: module.name)
                                .lineLimit(1)
                        }
                        .padding(10)
                    }
                    .background(.clear)
                    .frame(width: element_panel_width)
                    .overlay(alignment: .topTrailing)
                    {
                        if process_error != nil
                        {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.red)
                            #if os(macOS)
                                .font(.system(size: 8))
                            #else
                                .font(.system(size: 10))
                            #endif
                            #if os(macOS)
                                .padding(8)
                            #else
                                .padding(10)
                            #endif
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onChanged
                            { _ in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
                                {
                                    is_central_pressed = true
                                }
                            }
                            .onEnded
                            { _ in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
                                {
                                    is_expanded = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                                    {
                                        is_central_pressed = false
                                    }
                                }
                            }
                            .simultaneously(
                                with:
                                    TapGesture()
                                    .onEnded
                                    {
                                        is_central_pressed = true
                                        
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
                                )
                    )
                    .help(module.name)
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
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75))
                            {
                                is_expanded = false
                            }
                        })
                        {
                            Image(systemName: "chevron.compact.down")
                                .padding(10)
                            #if os(iOS)
                                .font(.system(size: 16))
                            #endif
                        }
                        .buttonStyle(.borderless)
                        #if os(iOS)
                        .tint(.black)
                        #endif
                        .contentShape(Rectangle())
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: is_expanded)
                        
                        VStack
                        {
                            ZStack
                            {
                                CodeView(text: code, language: .javascript())
                                #if os(visionOS)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                #endif
                                    .frame(maxWidth: 512, maxHeight: 256)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(alignment: .bottomLeading)
                            {
                                if let error = process_error
                                {
                                    Button
                                    {
                                        process_error = nil
                                    }
                                    label:
                                    {
                                        //Label(error.localizedDescription, systemImage: "xmark.octagon.fill")
                                        ZStack
                                        {
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .foregroundStyle(.thinMaterial)
                                            
                                            VStack(alignment: .leading)
                                            {
                                                Label("Error", systemImage: "xmark.octagon.fill")
                                                
                                                ScrollView
                                                {
                                                    Text(error.localizedDescription)
                                                        .multilineTextAlignment(.leading)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .lineLimit(nil)
                                                    #if os(macOS)
                                                        .font(.system(size: 10))
                                                    #else
                                                        .font(.system(size: 14))
                                                    #endif
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .padding(8)
                                        }
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(
                                        maxHeight: {
                                            #if os(macOS)
                                            80
                                            #else
                                            96
                                            #endif
                                        }(),
                                        alignment: .bottom
                                    )
                                    .buttonStyle(.plain)
                                    .padding(8)
                                }
                            }
                            .frame(width: is_expanded ? element_control_width : 120)
                            
                            Button("Import...")
                            {
                                new_code_view_presented = true
                            }
                            .buttonStyle(.borderless)
                            #if os(iOS)
                            .tint(.black)
                            .padding(.vertical, 4)
                            #endif
                        }
                        .padding([.horizontal, .bottom], 10)
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .glassEffect(.regular, in: .rect(cornerRadius: 16, style: .continuous))
            .scaleEffect(is_central_pressed ? 1.05 : 1)
            .zIndex(1)
            
            Button
            {
                process_changer()
            }
            label:
            {
                ZStack
                {
                    Image(systemName: "wand.and.rays")
                        .foregroundColor(.white)
                        .font(.system(size: 18)) //.imageScale(.large)
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                    #if os(macOS)
                        .frame(width: 48, height: 48)
                    #elseif os(iOS)
                        .frame(width: 56, height: 56)
                    #elseif os(visionOS)
                        .frame(width: 56, height: 56)
                    #endif
                }
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive().tint(.pink), in: .rect(cornerRadius: 16, style: .continuous))
        }
        .sheet(isPresented: $new_code_view_presented)
        {
            CodeSelectorView(
                is_presented: $new_code_view_presented,
                avaliable_template_names: [
                    "ChangerFunction"
                ]
            )
            { output in
                module.changer_function_code = output
                on_update()
            }
        }
        #if os(visionOS)
        .offset(z: 2)
        #endif
    }
    
    private func process_changer()
    {
        process_error = nil
        
        let changer_element = Changer(module: module)
        let registers_count = registers.count
        
        do
        {
            try changer_element.change(&registers)
            check_registers(registers_count)
        }
        catch
        {
            check_registers(registers_count)
            process_error = error
        }
        
        func check_registers(_ reference_count: Int)
        {
            if registers.count != reference_count
            {
                registers = updated_registers(registers, reference_count)
            }
        }
        
        func updated_registers(_ registers: [Float], _ new_count: Int) -> [Float]
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
}

#if os(macOS)
internal let element_control_width: CGFloat = 272
internal let element_panel_width: CGFloat = 120
#elseif os(iOS)
internal let element_control_width: CGFloat = 370
internal let element_panel_width: CGFloat = 140
#elseif os(visionOS)
internal let element_control_width: CGFloat = 400
internal let element_panel_width: CGFloat = 160
#endif

#Preview
{
    @Previewable @State var module = ChangerModule(name: "Module")
    @Previewable @State var registers = [Float](repeating: 0, count: 16)
    
    VStack(spacing: 0)
    {
        Spacer()
        
        ChangerModuleControl(module: module, registers: $registers, on_update: {})
            .padding()
    }
    #if !os(visionOS)
    .frame(width: 400, height: 440)
    #endif
    .padding()
}
