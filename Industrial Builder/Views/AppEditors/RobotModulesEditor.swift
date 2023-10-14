//
//  RobotModulesEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 13.10.2023.
//

import SwiftUI

struct RobotModulesEditor: View
{
    @Binding var is_presented: Bool
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Modules for Robot")
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
        .modifier(SheetFramer())
    }
}

#Preview
{
    RobotModulesEditor(is_presented: .constant(true))
}
