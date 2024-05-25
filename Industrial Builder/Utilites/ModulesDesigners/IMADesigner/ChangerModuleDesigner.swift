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
                Text("Code").tag(0)
                Text("Description").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                CodeEditorView(code: $changer_module.internal_code)
                {
                    document_handler.document_update_ima()
                }
            default:
                TextEditor(text: $changer_module.description)
                    .textFieldStyle(.plain)
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
