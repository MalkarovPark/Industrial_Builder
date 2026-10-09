//
//  InspectorItem.swift
//  Industrial Builder
//
//  Created by Artem on 04.03.2026.
//

import SwiftUI

public struct InspectorItem<Content: View>: View
{
    let label: String
    let content: Content
    
    @State var is_expanded: Bool
    
    public init(
        label: String,
        is_expanded: Bool = true,
        
        @ViewBuilder content: () -> Content
    )
    {
        self.is_expanded = is_expanded
        self.label = label
        
        self.content = content()
    }
    
    public var body: some View
    {
        #if os(macOS) || os(iOS)
        GroupBox
        {
            DisclosureGroup(isExpanded: $is_expanded)
            {
                content
                #if os(macOS)
                    .padding(5)
                #elseif os(iOS)
                    .padding(.top, 10)
                #endif
            }
            label:
            {
                Text(label)
                #if os(macOS)
                    .font(.system(size: 14))
                #elseif os(iOS)
                    .font(.system(size: 18))
                    .tint(.black)
                #endif
            }
        }
        .padding([.horizontal, .bottom], 10)
        #else
        VStack(spacing: 0)
        {
            DisclosureGroup(isExpanded: $is_expanded)
            {
                content
                    .padding([.horizontal, .bottom], 16)
            }
            label:
            {
                Text(label)
                    .font(.system(size: 18))
            }
        }
        .background
        {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.regularMaterial)
        }
        .padding([.horizontal, .bottom], 10)
        #endif
    }
}
