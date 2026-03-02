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
    
    public let on_update: () -> ()
    
    @State private var is_expanded = false
    @State private var is_central_pressed = false
    
    @Namespace private var pane_glass
    
    @State private var code_editor_presented = false
    @State private var new_code_view_presented = false
    
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
                        
                        VStack
                        {
                            ZStack
                            {
                                CodeView(text: code, language: .javascript())
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Button("Import...", action: { new_code_view_presented = true })
                            #if os(iOS)
                                .padding(.vertical, 4)
                            #endif
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
        .sheet(isPresented: $new_code_view_presented)
        {
            #if os(macOS)
            CodeSelectorView(is_presented: $new_code_view_presented, avaliable_template_names: all_code_templates)
            { output in
                module.changer_function_code = output
                on_update()
            }
            #else
            CodeSelectorView(is_presented: $new_code_view_presented,
                            avaliable_templates_names: all_code_templates,
                            bottom_view:
                                TextField("Name", text: $new_listing_name)
                                    .padding(.trailing)
                                    .frame(minWidth: 128, maxWidth: 256)
                                    .frame(idealWidth: 256)
                                    .textFieldStyle(.roundedBorder)
            )
            { output in
                module.changer_function_code = output
                on_update()
            }
            #endif
        }
    }
}
