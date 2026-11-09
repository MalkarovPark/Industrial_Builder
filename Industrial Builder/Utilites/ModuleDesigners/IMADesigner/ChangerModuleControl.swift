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
    
    @State private var code_editor_presented = false
    @State private var new_code_view_presented = false
    @State private var process_error: Error?
    
    @State private var is_expanded = false
    @State private var is_central_pressed = false
    
    @Namespace private var pane_glass
    
    private let element_button_height: CGFloat = 48
    #if os(macOS)
    private let element_button_min_height: CGFloat = 20
    #else
    private let element_button_min_height: CGFloat = 24
    #endif
    
    public var body: some View
    {
        ZStack
        {
            if !is_expanded
            {
                // Element Pane
                VStack
                {
                    Spacer()
                    
                    MarqueeText(
                        "Module - \(module.name)",
                        font: .system(size: 10),
                        leading_inset: 12
                    )
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: is_expanded)
                    .frame(height: (120 - 48) / 2)
                }
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onChanged
                        { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
                            {
                                is_central_pressed = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
                                    {
                                        is_central_pressed = false
                                    }
                                }
                            }
                        }
                        .onEnded
                        { _ in
                            tap_action()
                        }
                        .simultaneously(
                            with:
                                TapGesture()
                                .onEnded
                                {
                                    is_central_pressed = false
                                    
                                    tap_action()
                                }
                            )
                )
                .frame(width: 120, height: 120)
                .help("Module - \(module.name)")
            }
            else
            {
                // Editor
                VStack(alignment: .leading, spacing: 0)
                {
                    Button(action: collapse_tap_action)
                    {
                        Image(systemName: "xmark")
                            .padding(10)
                        #if os(iOS)
                            .font(.system(size: 16))
                        #endif
                    }
                    .buttonStyle(.borderless)
                    #if os(iOS)
                    .tint(.black)
                    #endif
                    .buttonBorderShape(.circle)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: is_expanded)
                    
                    VStack
                    {
                        /*GroupBox
                        {
                            ChangerModuleCode(
                                module: module,
                                process_error: $process_error,
                                on_update: on_update
                            )
                        }*/
                        
                        ChangerModuleCode(
                            module: module,
                            process_error: $process_error,
                            on_update: on_update
                        )
                    }
                    .padding(.horizontal, 10)
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: element_button_min_height + 9.5 * 2)
                }
                //.frame(width: element_control_width)
                .animation(.spring(response: 0.35, dampingFraction: 0.95), value: is_expanded)
            }
        }
        .overlay(alignment: !is_expanded ? .center : .bottom)
        {
            // Element Button
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
                        .font(.system(size: 18))
                        .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                        .frame(
                            width: !is_expanded ? element_button_height : (element_control_width - 20) / 2,
                            height: !is_expanded ? element_button_height : element_button_min_height
                        )
                        .scaleEffect(!is_expanded ? 1 : 0.75)
                }
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .glassEffect(.regular.tint(.pink), in: .rect(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .topTrailing)
                {
                    if process_error != nil
                    {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.clear)
                            .glassEffect(.regular.tint(.red), in: .circle)
                            .brightness(0.2)
                            .font(.system(size: 6))
                            .padding(6)
                            .allowsHitTesting(false)
                    }
                }
            }
            .buttonStyle(.plain)
            .buttonBorderShape(.roundedRectangle(radius: 10))
            .padding(9.5)//(10)
        }
        .overlay(alignment: .top)
        {
            // New Element Menu
            VStack
            {
                Button
                {
                    new_code_view_presented = true
                }
                label:
                {
                    #if os(macOS) || os(iOS)
                    Text("Changer")
                        .font(
                            .system(
                                size: {
                                #if os(macOS)
                                    14
                                #elseif os(iOS)
                                    16
                                #endif
                                }(),
                                design: .rounded
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .frame(
                            height: !is_expanded
                            ? {
                            #if os(macOS)
                                16
                            #elseif os(iOS)
                                16
                            #endif
                            }()
                            : {
                            #if os(macOS)
                                12
                            #elseif os(iOS)
                                16
                            #endif
                            }()
                        )
                    #else
                    Text("Changer")
                        .font(.system(size: !is_expanded ? 16 : 18, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .frame(height: !is_expanded ? 16 : 24)
                    #endif
                }
                .menuIndicator(.hidden)
                .buttonStyle(.plain)
                .padding(10)
                #if os(iOS)
                .tint(.black)
                #elseif os(visionOS)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                #endif
                
                Spacer()
            }
            .frame(width: 120, height: 120)
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
        }
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .glassEffect(.regular, in: .rect(cornerRadius: 16, style: .continuous))
        .scaleEffect(is_central_pressed ? 1.05 : 1)
        .zIndex(1)
        #if os(visionOS)
        .offset(z: 2)
        #endif
    }
    
    // MARK: – Central press actions
    private func tap_action()
    {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85))
        {
            is_expanded = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                is_central_pressed = false
            }
        }
    }
    
    private func collapse_tap_action()
    {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75))
        {
            is_expanded = false
        }
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

private struct MarqueeText: View
{
    let text: String
    var font: Font
    var spacing: CGFloat
    var points_per_second: CGFloat
    var pause_duration: Duration
    var leading_inset: CGFloat
    
    @State private var text_width: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var needs_scrolling = false
    
    private let gradient_margin: CGFloat = 0.04
    private let gradient_gap: CGFloat = 0.08
    
    init(
        _ text: String,
        font: Font = .system(size: 16),
        spacing: CGFloat = 32,
        points_per_second: CGFloat = 30,
        pause_duration: Duration = .seconds(1.5),
        leading_inset: CGFloat = 0
    )
    {
        self.text = text
        self.font = font
        self.spacing = spacing
        self.points_per_second = points_per_second
        self.pause_duration = pause_duration
        self.leading_inset = leading_inset
    }
    
    var body: some View
    {
        GeometryReader
        { geometry in
            let viewport_width = geometry.size.width
            //let needs_scrolling = text_width > viewport_width
            let distance = text_width + spacing
            let duration = Double(distance / max(points_per_second, 1))
            
            HStack(spacing: spacing)
            {
                Text(text)
                    .fixedSize()
                
                if needs_scrolling
                {
                    Text(text)
                        .fixedSize()
                        .accessibilityHidden(true)
                }
            }
            .font(font)
            .offset(x: offset)
            //.frame(height: geometry.size.height, alignment: .leading)
            .frame(
                width: needs_scrolling ? nil : viewport_width,
                height: geometry.size.height,
                alignment: needs_scrolling ? .leading : .center
            )
            .padding(.leading, needs_scrolling ? leading_inset : 0)
            .clipped()
            .background
            {
                Text(text)
                    .font(font)
                    .fixedSize()
                    .hidden()
                    .background
                {
                    GeometryReader
                    { text_geometry in
                        Color.clear
                            .onAppear
                        {
                            text_width = text_geometry.size.width
                        }
                        .onChange(of: text_geometry.size.width)
                        { _, new_width in
                            text_width = new_width
                        }
                    }
                }
            }
            .task(id: "\(text)-\(text_width)-\(viewport_width)")
            {
                offset = 0
                guard needs_scrolling else { return }
                
                while !Task.isCancelled
                {
                    try? await Task.sleep(for: pause_duration)
                    guard !Task.isCancelled else { break }
                    
                    withAnimation(.linear(duration: duration))
                    {
                        offset = -distance
                    }
                    try? await Task.sleep(for: .seconds(duration))
                    guard !Task.isCancelled else { break }
                    
                    var transaction = Transaction()
                    transaction.animation = nil
                    withTransaction(transaction) { offset = 0 }
                }
            }
            .onAppear { needs_scrolling = text_width > viewport_width }
        }
        .accessibilityLabel(text)
        .mask
        {
            if needs_scrolling
            {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: gradient_margin),
                        .init(color: .black, location: gradient_margin + gradient_gap),
                        .init(color: .black, location: 1 - gradient_margin - gradient_gap),
                        .init(color: .clear, location: 1 - gradient_margin)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            else
            {
                Rectangle()
            }
        }
    }
}

#if os(macOS)
internal let element_control_width: CGFloat = 240
internal let element_control_height: CGFloat = 260 //240
#elseif os(iOS)
internal let element_control_width: CGFloat = 320
internal let element_control_height: CGFloat = 370 //320
#elseif os(visionOS)
internal let element_control_width: CGFloat = 320
internal let element_control_height: CGFloat = 420 //320
#endif

private struct ChangerModuleCode: View
{
    @ObservedObject var module: ChangerModule
    
    @Binding var process_error: Error?
    
    let on_update: () -> ()
    
    @State private var code_editor_presented = false
    @State private var new_code_view_presented = false
    
    var body: some View
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
        
        VStack
        {
            ZStack
            {
                CodeView(text: code, language: .javascript())
                #if os(visionOS)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                #endif
                    .frame(maxHeight: 256)
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
                    .buttonBorderShape(.roundedRectangle(radius: 6))
                    .padding(8)
                }
            }
            //.frame(width: is_expanded ? element_control_width : 120)
        }
    }
}

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
