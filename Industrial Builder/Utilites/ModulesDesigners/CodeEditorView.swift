//
//  CodeEditorView.swift
//  Industrial Builder
//
//  Created by Artem on 25.05.2024.
//

import SwiftUI

struct CodeEditorView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var code: String
    
    @State private var code_file_name = String()
    @State private var code_field_update = false
    
    public var update_document_func: () -> ()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            TextEditor(text: $code)
                //.modifier(TextFrame())
                .textFieldStyle(.plain)
                //.frame(minHeight: 256, maxHeight: 512)
                .modifier(DoubleModifier(update_toggle: $code_field_update))
            
            Divider()
            
            HStack
            {
                Picker(selection: $code_file_name, label: Text("Listing"))
                {
                    ForEach(base_stc.listings_files_names, id: \.self)
                    { listing_file_name in
                        Text(listing_file_name)
                    }
                }
                .buttonStyle(.bordered)
                
                Button(action: push_code_internal)
                {
                    Image(systemName: "arrow.up.doc")
                }
                .buttonStyle(.bordered)
            }
            .disabled(base_stc.listings_files_names.count == 0)
            .padding()
        }
        //.padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear
        {
            if base_stc.listings_files_names.count > 0
            {
                code_file_name = base_stc.listings_files_names.first!
            }
        }
    }
    
    private func push_code_internal()
    {
        guard let index = base_stc.listings_files_names.firstIndex(where: { $0 == code_file_name })
        else
        {
            return
        }
        
        code = base_stc.listings[index]
        code_field_update.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            update_document_func()
        }
    }
}

#Preview
{
    CodeEditorView(code: .constant("Code"))
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
        
        CodeEditorView(code: .constant(""))
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
