//
//  ChangerInspectorView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 01.03.2026.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI
import LanguageSupport

struct ChangerInspectorView: View
{
    @ObservedObject var module: ChangerModule
    
    public let on_update: () -> ()
    
    @State private var description_expanded = true
    
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
            }
        }
    }
}
