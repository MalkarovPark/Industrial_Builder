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
    
    let label: String
    @Binding var text: String
    let avaliable_template_names: [String]
    
    let on_update: () -> ()
    
    @State private var new_code_view_presented = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    init(
        is_presented: Binding<Bool>,
        label: String,
        
        text: Binding<String>,
        avaliable_template_names: [String] = [],
        
        on_update: @escaping () -> Void = {}
    )
    {
        self.label = label
        self._is_presented = is_presented
        self._text = text
        
        self.avaliable_template_names = avaliable_template_names
        
        self.on_update = on_update
    }
    
    var body: some View
    {
        let code_text = Binding(
            get: { text },
            set:
                { new_value in
                    text = new_value
                    
                    on_update()
                }
        )
        
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                Spacer()
                
                Button(action: { new_code_view_presented = true })
                {
                    Image(systemName: "square.and.arrow.down")
                        .modifier(CircleButtonImageFramer())
                }
                .keyboardShortcut(.cancelAction)
                #if !os(visionOS)
                .modifier(CircleButtonGlassBorderer())
                #else
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .buttonStyle(.bordered)
                #endif
                .keyboardShortcut(.cancelAction)
                #if os(macOS) || os(iOS)
                .padding(10)
                #else
                .padding(16)
                #endif
            }
            .sheet(isPresented: $new_code_view_presented)
            {
                CodeSelectorView(
                    is_presented: $new_code_view_presented,
                    avaliable_template_names: avaliable_template_names
                )
                { output in
                    text = output
                }
            }
            
            CodeView(text: code_text, language: .javascript())
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: label, plain: false, clear_background: true))
        #if os(macOS) || os(visionOS)
        .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #endif
        #if os(iOS)
        .background(.white)
        #endif
    }
}

#Preview
{
    @Previewable @State var code = "print(output)"
    CodeEditorView(is_presented: .constant(true), label: "Sources", text: $code)
}
