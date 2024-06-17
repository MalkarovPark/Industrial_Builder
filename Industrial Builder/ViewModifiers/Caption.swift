//
//  Caption.swift
//  Industrial Builder
//
//  Created by Artem on 26.04.2024.
//

import SwiftUI

struct Caption: ViewModifier
{
    @Binding var is_presented: Bool
    
    let label: String
    
    func body(content: Content) -> some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {
                HStack(alignment: .center)
                {
                    Text(label)
                        .padding(0)
                    #if os(visionOS)
                        .font(.title2)
                        .padding(.vertical)
                    #endif
                }
                
                HStack(spacing: 0)
                {
                    Button(action: { is_presented = false })
                    {
                        Image(systemName: "xmark")
                    }
                    .keyboardShortcut(.cancelAction)
                    #if !os(visionOS)
                    .buttonStyle(.borderless)
                    .controlSize(.extraLarge)
                    #else
                    .buttonBorderShape(.circle)
                    .buttonStyle(.bordered)
                    #endif
                    .padding()
                    
                    Spacer()
                }
            }
            
            #if !os(visionOS)
            Divider()
            #endif
            
            content
        }
    }
}
