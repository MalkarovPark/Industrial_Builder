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
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var code_items: [CodeItem]
    
    @State private var code_item_name = String()
    @State private var code_field_update = false
    
    public var update_document_func: () -> ()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            TextEditor(text: $code_items[code_item_index()].code)
                .textFieldStyle(.plain)
                .modifier(DoubleModifier(update_toggle: $code_field_update))
            
            Divider()
            
            HStack(spacing: 0)
            {
                Picker(selection: $code_item_name, label: Text("Item"))
                {
                    ForEach(code_items_names(), id: \.self)
                    { code_item_name in
                        Text(code_item_name)
                    }
                }
                //.labelsHidden()
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .padding(.trailing)
                .disabled(code_items.count == 1)
                
                Menu("Import From...")
                {
                    ForEach (base_stc.listings_files_names, id: \.self)
                    { name in
                        Button(name)
                        {
                            import_from_listing(name)
                        }
                    }
                }
                #if os(macOS)
                .menuStyle(.borderedButton)
                #else
                .modifier(PickerBorderer())
                #endif
                .frame(width: 112)
                .disabled(base_stc.listings_files_names.count == 0)
            }
            .disabled(base_stc.listings_files_names.count == 0)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear
        {
            if base_stc.listings_files_names.count > 0
            {
                code_item_name = code_items_names().first!
            }
        }
    }
    
    private func code_items_names() -> [String]
    {
        var names = [String]()
        for code_item in code_items
        {
            names.append(code_item.name)
        }
        
        return names
    }
    
    private func code_item_index() -> Int
    {
        guard let index = code_items_names().firstIndex(where: { $0 == code_item_name })
        else
        {
            return 0
        }
        
        return index
    }
    
    private func import_from_listing(_ file_name: String)
    {
        guard let index = base_stc.listings_files_names.firstIndex(where: { $0 == file_name })
        else
        {
            return
        }
        
        code_items[code_item_index()].code = base_stc.listings[index]
        //code_field_update.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            code_field_update.toggle()
            update_document_func()
        }
    }
}

#Preview
{
    CodeEditorView(code_items: .constant([CodeItem()]))
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
        
        CodeEditorView(code_items: .constant([CodeItem()]))
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
