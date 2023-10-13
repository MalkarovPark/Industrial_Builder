//
//  ToolModulesEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 13.10.2023.
//

import SwiftUI

struct ToolModulesEditor: View
{
    @Binding var is_presented: Bool
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Modules for Tool")
                .font(.title2)
            #if os(visionOS)
                .padding(24)
            #else
                .padding()
            #endif
            
            GroupBox
            {
                VStack(spacing: 0)
                {
                    Text("None")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding([.horizontal, .bottom])
        }
        .modifier(ViewCloseButton(is_presented: $is_presented))
        .modifier(WindowFramer())
    }
}

#Preview
{
    ToolModulesEditor(is_presented: .constant(true))
}
