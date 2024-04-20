//
//  ChangerModuleEditor.swift
//  Industrial Builder
//
//  Created by Artem on 12.10.2023.
//

import SwiftUI
import IndustrialKit

struct ChangerModuleView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var changer_module: ChangerModule
    
    //@State private var appeared = false
    @State private var add_module_view_presented = false
    @State private var code_file_name = String()
    
    @State private var code_field_update = false
    
    var body: some View
    {
        List
        {
            TextField("Name", text: $changer_module.name)
            
            Section("Description")
            {
                TextEditor(text: $changer_module.description)
                    .modifier(TextFrame())
            }
            
            Section("Code")
            {
                TextEditor(text: $changer_module.internal_code)
                    .modifier(TextFrame())
                    .frame(maxHeight: 256)
                    .modifier(DoubleModifier(update_toggle: $code_field_update))
                
                Toggle(isOn: $changer_module.is_internal_change)
                {
                    Text("Internal")
                }
                
                HStack
                {
                    Picker(selection: $code_file_name, label: Text("File"))
                    {
                        ForEach(base_stc.listings_files_names, id: \.self)
                        { listing_file_name in
                            Text(listing_file_name)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: push_code_internal)
                    {
                        Text("To Internal")
                        Image(systemName: "arrow.up.doc")
                    }
                }
                .disabled(base_stc.listings_files_names.count == 0)
            }
        }
        .listStyle(.plain)
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
        
        changer_module.internal_code = base_stc.listings[index]
        code_field_update.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            document_handler.document_update_ima()
        }
        //document_handler.document_update_ima()
    }
}

#Preview
{
    ChangerModuleView(changer_module: .constant(ChangerModule(name: "None")))
        .environmentObject(StandardTemplateConstruct())
}
