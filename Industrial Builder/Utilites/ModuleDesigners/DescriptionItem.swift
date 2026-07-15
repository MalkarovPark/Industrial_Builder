//
//  DescriptionItem.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 15.07.2026.
//

import SwiftUI

import IndustrialKit

public struct DescriptionItem: View
{
    let module: IndustrialModule
    
    let on_update: () -> Void
    
    public init
    (
        module: IndustrialModule,
        
        on_update: @escaping () -> Void
    )
    {
        self.module = module
        
        self.on_update = on_update
    }
    
    public var body: some View
    {
        InspectorItem(label: "Description", is_expanded: true)
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
            #if !os(visionOS)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            #else
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            #endif
                .frame(minHeight: 80, maxHeight: 160)
        }
    }
}
