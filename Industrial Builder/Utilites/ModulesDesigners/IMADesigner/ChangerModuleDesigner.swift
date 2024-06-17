//
//  ChangerModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 12.10.2023.
//

import SwiftUI
import IndustrialKit

struct ChangerModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var changer_module: ChangerModule
    
    @State private var editor_selection = 0
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $editor_selection, label: Text("Picker"))
            {
                Text("Description").tag(0)
                Text("Code").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $changer_module.description)
                    .textFieldStyle(.plain)
            default:
                CodeEditorView(code_items: $changer_module.code_items)
                {
                    document_handler.document_update_ima()
                }
            }
        }
        .background(.white)
    }
}

#Preview
{
    ChangerModuleDesigner(changer_module: .constant(ChangerModule(name: "None")))
        .environmentObject(StandardTemplateConstruct())
}
