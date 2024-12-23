//
//  CodeBuilderView.swift
//  Industrial Builder
//
//  Created by Artem on 09.11.2024.
//

import SwiftUI

struct CodeBuilderView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct        
    
    @Binding var code: String
    
    public var avaliable_templates_names: [String] = [String]()
    public var model_name: String
    
    public var update_document_func: () -> () = { }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if !avaliable_templates_names.isEmpty
            {
                if avaliable_templates_names.count > 1
                {
                    Menu("Import from Template")
                    {
                        ForEach(avaliable_templates_names, id: \.self)
                        { name in
                            Button(name)
                            {
                                import_from_template(name)
                            }
                        }
                    }
                    #if os(macOS)
                    .menuStyle(.borderedButton)
                    #else
                    .modifier(PickerBorderer())
                    #endif
                    //.disabled(base_stc.listings_files_names.isEmpty)
                    .padding(.bottom)
                }
                else
                {
                    Button("Import from Template")
                    {
                        import_from_template(avaliable_templates_names.first ?? "")
                    }
                    #if os(macOS)
                    .buttonStyle(.bordered)
                    #else
                    .modifier(PickerBorderer())
                    #endif
                    .padding(.bottom)
                }
            }
            
            Menu("Import from File")
            {
                ForEach(base_stc.listings_files_names, id: \.self)
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
            .disabled(base_stc.listings_files_names.isEmpty)
        }
        .padding()
    }
    
    private func import_from_template(_ file_name: String)
    {
        code = import_text_data(from: file_name).replacingOccurrences(of: "<#Name#>", with: model_name.code_correct_format())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            //code_field_update.toggle()
            update_document_func()
        }
    }
    
    private func import_from_listing(_ file_name: String)
    {
        guard let index = base_stc.listings_files_names.firstIndex(of: file_name) else {
            return
        }
        
        code = base_stc.listings[index]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            //code_field_update.toggle()
            update_document_func()
        }
    }
}

#Preview
{
    CodeBuilderView(code: .constant("Code"), avaliable_templates_names: ["UwU", "OwO"], model_name: "Name")
        .environmentObject(StandardTemplateConstruct())
        .frame(width: 256)
}
