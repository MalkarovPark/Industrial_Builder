//
//  CodeEditorView.swift
//  Industrial Builder
//
//  Created by Artem on 25.05.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct CodeEditorView: View
{
    @Binding var is_presented: Bool
    
    @Binding var code: String
    
    @State private var new_code_view_presented = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        #if os(macOS) || os(visionOS)
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                Spacer()
                
                Button
                {
                    new_code_view_presented = true
                }
                label:
                {
                    Image(systemName: "square.and.arrow.down")
                    #if !os(macOS)
                        .imageScale(.large)
                    #if !os(visionOS)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.black)
                    #else
                        .foregroundStyle(.white)
                    #endif
                    #endif
                }
                #if os(macOS)
                .buttonStyle(.borderless)
                .padding(11)
                #else
                .buttonBorderShape(.circle)
                #if !os(visionOS)
                .padding(15)
                #endif
                #endif
                #if !os(visionOS)
                .glassEffect()
                #else
                .padding(4)
                .buttonStyle(.borderless)
                .glassBackgroundEffect()
                .padding(6)
                #endif
            }
            .padding(10)
            .sheet(isPresented: $new_code_view_presented)
            {
                #if os(macOS)
                CodeBuilderView(is_presented: $new_code_view_presented, avaliable_templates_names: all_code_templates)
                { output in
                    code = output
                }
                #else
                CodeBuilderView(is_presented: $new_code_view_presented,
                                avaliable_templates_names: all_code_templates,
                                bottom_view:
                                    TextField("Name", text: $new_listing_name)
                                        .padding(.trailing)
                                        .frame(minWidth: 128, maxWidth: 256)
                                        .frame(idealWidth: 256)
                                        .textFieldStyle(.roundedBorder)
                )
                { output in
                    code = output
                }
                #endif
            }
            
            CodeView(text: $code, language: .javascript())
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: "Changer Func", plain: false, clear_background: true))
        .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #else
        if horizontal_size_class != .compact
        {
            VStack(spacing: 0)
            {
                CodeView(text: code_text)
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: listing_item.name))
            .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        }
        else
        {
            VStack(spacing: 0)
            {
                CodeView(text: code_text)
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: listing_item.name))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #endif
    }
}

#Preview
{
    @Previewable @State var code = "print(output)"
    CodeEditorView(is_presented: .constant(true), code: $code)
}
