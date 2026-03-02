//
//  ChangerInspectorView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 01.03.2026.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI
import LanguageSupport

struct ChangerInspectorView: View
{
    @ObservedObject var module: ChangerModule
    
    public let on_update: () -> ()
    
    @State private var description_expanded = true
    @State private var code_expanded = true
    
    @State private var code_editor_presented = false
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 0)
            {
                let name = Binding(
                    get: { module.name },
                    set:
                        { new_value in
                            module.name = new_value
                            
                            on_update()
                        }
                )
                
                let code = Binding(
                    get: { module.changer_function_code },
                    set:
                        { new_value in
                            module.changer_function_code = new_value
                            
                            on_update()
                        }
                )
                
                TextField("None", text: name)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
                
                Divider()
                
                DisclosureGroup(isExpanded: $description_expanded)
                {
                    let description = Binding(
                        get: { module.description },
                        set:
                            { new_value in
                                module.description = new_value
                                
                                on_update()
                            }
                    )
                    
                    TextEditor(text: description)
                        .multilineTextAlignment(.leading)
                        .textFieldStyle(.roundedBorder)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .frame(minHeight: 80)
                }
                label:
                {
                    Text("Description")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(10)
                
                Divider()
                
                DisclosureGroup(isExpanded: $code_expanded)
                {
                    ZStack
                    {
                        ZStack
                        {
                            ScrollView
                            {
                                if !module.changer_function_code.isEmpty
                                {
                                    Text(module.changer_function_code)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    #if os(macOS)
                                        .font(.custom("Menlo", size: 10))
                                    #else
                                        .font(.custom("Menlo", size: 14))
                                    #endif
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if module.changer_function_code.isEmpty
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
                        .frame(height: 120)
                        .overlay(alignment: .bottomTrailing)
                        {
                            Button
                            {
                                code_editor_presented = true
                            }
                            label:
                            {
                                Image(systemName: "pencil")
                            }
                            .padding(10)
                        }
                    }
                    .sheet(isPresented: $code_editor_presented)
                    {
                        CodeEditorView(is_presented: $code_editor_presented, code: code)
                    }
                }
                label:
                {
                    Text("Code")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(10)
                
                Divider()
            }
        }
    }
}
