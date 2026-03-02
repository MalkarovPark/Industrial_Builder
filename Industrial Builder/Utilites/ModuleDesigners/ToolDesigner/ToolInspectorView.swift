//
//  ToolInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 02.03.2026.
//

import SwiftUI
import IndustrialKit

struct ToolInspectorView: View
{
    @ObservedObject var module: ToolModule
    
    @Binding var entity_selector_presented: Bool
    
    public let on_update: () -> ()
    
    @State private var description_expanded = true
    @State private var entity_expanded = true
    
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
                
                DisclosureGroup(isExpanded: $entity_expanded)
                {
                    HStack
                    {
                        if let entity_file_name = module.entity_file_name
                        {
                            Text(entity_file_name)
                                .frame(maxWidth: .infinity)
                            
                            Button
                            {
                                module.entity_file_name = nil
                                on_update()
                            }
                            label:
                            {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        else
                        {
                            Text("None")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button
                        {
                            entity_selector_presented = true
                        }
                        label:
                        {
                            Image(systemName: "arrowshape.right.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                label:
                {
                    Text("Entity")
                        .font(.system(size: 13, weight: .bold))
                }
                .padding(10)
                
                Divider()
            }
        }
    }
}
