//
//  CodeEditorView.swift
//  Industrial Builder
//
//  Created by Artem on 25.05.2024.
//

import SwiftUI
import IndustrialKit

struct CodeEditorView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var code_items: [String: String]
    
    @State private var code_item_name = String()
    @State private var code_field_update = false
    
    @State private var code_builder_presented = false
    
    public var avaliable_templates_names: [String: [String]] = [:]
    public var model_name: String
    
    public var update_document_func: () -> ()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            TextEditor(text: Binding(
                get: { code_items[code_item_name] ?? "" },
                set: { code_items[code_item_name] = $0 }
            ))
            .textFieldStyle(.plain)
            .modifier(DoubleModifier(update_toggle: $code_field_update))
            
            Divider()
            
            HStack(spacing: 0)
            {
                Picker(selection: $code_item_name, label: Text("Item"))
                {
                    ForEach(Array(code_items.keys), id: \.self)
                    { name in
                        Text(name)
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .padding(.trailing)
                .disabled(code_items.count == 1)
                
                Button("Build")
                {
                    code_builder_presented.toggle()
                }
                #if os(macOS)
                .menuStyle(.borderedButton)
                #else
                .modifier(PickerBorderer())
                #endif
                .popover(isPresented: $code_builder_presented, arrowEdge: .top)
                {
                    CodeBuilderView(code: code_item_binding(from: $code_items, key: code_item_name), avaliable_templates_names: avaliable_templates_names[code_item_name] ?? [String](), model_name: model_name)
                    {
                        code_field_update.toggle()
                        update_document_func()
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear
        {
            if let firstKey = Array(code_items.keys).first
            {
                code_item_name = firstKey
            }
        }
    }
    
    private func import_from_listing(_ file_name: String)
    {
        guard let index = base_stc.listings_files_names.firstIndex(of: file_name) else {
            return
        }
        
        code_items[code_item_name] = base_stc.listings[index]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            code_field_update.toggle()
            update_document_func()
        }
    }
    
    private func code_item_binding(from dictionary: Binding<[String: String]>, key: String) -> Binding<String>
    {
        Binding<String>(
            get: { dictionary.wrappedValue[key] ?? "" },
            set: { newValue in dictionary.wrappedValue[key] = newValue }
        )
    }
}

#Preview
{
    CodeEditorView(code_items: .constant(["Code Item": "code"]), model_name: "Name")
    {
        
    }
    .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    VStack(spacing: 0)
    {
        Text("Code")
            .foregroundStyle(.secondary)
            .frame(maxHeight: 24)
        
        Divider()
        
        CodeEditorView(code_items: .constant(["Code Item": "code"]), model_name: "Name")
        {
            
        }
        .environmentObject(StandardTemplateConstruct())
    }
    .background
    {
        Rectangle()
            .foregroundStyle(.white)
            .shadow(radius: 1)
    }
}
