//
//  CodeEditorPane.swift
//  Industrial Builder
//
//  Created by Artem on 06.03.2026.
//

import SwiftUI

public struct CodeEditorPane: View
{
    let label: String
    
    @State private var code: String
    
    let on_update: (String) -> Void
    
    @State private var code_editor_presented = false
    
    public init(
        label: String,
        code: String,
        on_update: @escaping (String) -> Void = { _ in }
    )
    {
        self.label = label
        self.code = code
        
        self.on_update = on_update
    }
    
    public var body: some View
    {
        ZStack
        {
            ScrollView
            {
                if !code.isEmpty
                {
                    Text(code)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    #if os(macOS)
                        .font(.custom("Menlo", size: 10))
                    #else
                        .font(.custom("Menlo", size: 14))
                    #endif
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
            
            if code.isEmpty
            {
                Text("No Code")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    #if os(macOS)
                    .font(.system(size: 12))
                    #else
                    .font(.system(size: 16))
                    #endif
                    .foregroundStyle(.secondary)
            }
        }
        .background(.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(height: 96)
        .overlay(alignment: .bottomTrailing)
        {
            Button
            {
                code_editor_presented = true
            }
            label:
            {
                Image(systemName: "pencil")
                    .imageScale(.large)
                    .padding(4)
                    .background
                {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .sheet(isPresented: $code_editor_presented)
        {
            CodeEditorView(is_presented: $code_editor_presented, text: $code, label: label)
            {
                on_update(code)
            }
        }
    }
}

#Preview
{
    CodeEditorPane(label: "Code", code: "import IndustrialKit")
}
