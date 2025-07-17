//
//  LinkedComponentsView.swift
//  Industrial Builder
//
//  Created by Artem on 25.10.2024.
//

import SwiftUI

struct LinkedComponentsView: View
{
    @Binding var linked_components: [String: String]
    
    let on_update: () -> ()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ForEach(Array(linked_components.keys), id: \.self)
            { key in
                HStack(spacing: 0)
                {
                    TextField("\(key)", text: Binding(
                        get:
                            {
                                linked_components[safe: key, default: ""]
                            },
                        set:
                            {
                                linked_components[key] = $0.isEmpty ? "" : $0
                            }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    
                    Toggle(isOn: Binding(
                        get:
                            {
                                !linked_components[safe: key, default: String()].isEmpty
                            },
                        set:
                            { is_active in
                                if !is_active
                                {
                                    linked_components[key] = ""
                                }
                            }))
                    {
                        Image(systemName: "app.connected.to.app.below.fill")
                    }
                    .toggleStyle(.button)
                    .disabled(linked_components[key]?.isEmpty ?? true)
                    .padding(.leading)
                }
                .padding(.bottom)
            }
        }
        .controlSize(.regular)
        .padding([.horizontal, .top])
        .onChange(of: linked_components)
        { _, _ in
            on_update()
        }
    }
}

#Preview
{
    LinkedComponentsView(linked_components: .constant(["Component": "Module", "Component2": ""]), on_update: {})
}
