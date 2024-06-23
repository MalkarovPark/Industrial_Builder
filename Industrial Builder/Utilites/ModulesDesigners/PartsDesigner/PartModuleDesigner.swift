//
//  PartsModuleDesigner.swift
//  Industrial Builder
//
//  Created by Artem on 23.04.2024.
//

import SwiftUI
import IndustrialKit

struct PartModuleDesigner: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var part_module: PartModule
    
    @State private var editor_selection = 0
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $editor_selection, label: Text("Picker"))
            {
                Text("Description").tag(0)
                Text("Resources").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            
            Divider()
            
            switch editor_selection
            {
            case 0:
                TextEditor(text: $part_module.description)
                    .textFieldStyle(.plain)
            default:
                ResourcesPackageView(resources_names: $part_module.resources_names, main_scene_name: $part_module.main_scene_name)
            }
        }
        .background(.white)
    }
}

#Preview
{
    PartModuleDesigner(part_module: .constant(PartModule()))
        .environmentObject(StandardTemplateConstruct())
}
