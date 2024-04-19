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
    
    @State private var appeared = false
    @State private var add_module_view_presented = false
    
    @State private var code_field_update = false
    @State private var file_field_update = false
    
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
                
                Toggle(isOn: is_external_binding(from: $changer_module.internal_code))
                {
                    Text("Internal")
                }
                
                HStack
                {
                    TextField("File", text: $changer_module.code_file_name)
                        .modifier(DoubleModifier(update_toggle: $file_field_update))
                    
                    Menu
                    {
                        ForEach(base_stc.listings_files_names, id: \.self)
                        { listing_file_name in
                            Button(listing_file_name)
                            {
                                changer_module.code_file_name = listing_file_name
                                file_field_update.toggle()
                            }
                        }
                    }
                    label:
                    {
                        Text("Select File")
                    }
                    .frame(width: 96)
                    
                    Button(action: push_code_internal)
                    {
                        Text("To Internal")
                        Image(systemName: "arrow.up.doc")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func is_external_binding(from code: Binding<String>) -> Binding<Bool>
    {
        Binding<Bool>(
            get: { !code.wrappedValue.isEmpty },
            set: { code.wrappedValue = $0 ? code.wrappedValue : "" }
        )
    }
    
    private func push_code_internal()
    {
        guard let index = base_stc.listings_files_names.firstIndex(where: { $0 == changer_module.code_file_name })
        else
        {
            return
        }
        
        changer_module.internal_code = base_stc.listings[index]
        code_field_update.toggle()
    }
}

#Preview
{
    ChangerModuleView(changer_module: .constant(ChangerModule(name: "None")))
        .environmentObject(StandardTemplateConstruct())
}
