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
        DisclosureGroup(isExpanded: $is_expanded)
        {
            content
        }
        label:
        {
            Text(label)
                .font(.system(size: 13, weight: .bold))
        }
        .padding(10)
        
        Divider()
    }
}
