//
//  ModelSelectorView.swift
//  Industrial Builder
//
//  Created by Artem on 04.11.2023.
//

import SwiftUI
import IndustrialKitUI

struct EntitySelectorView: View
{
    @Binding var is_presented: Bool
    
    public var on_select: (String) -> ()
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 128, maximum: .infinity), spacing: 24)]
    private let card_spacing: CGFloat = 24
    private let card_height: CGFloat = 128
    
    #if !os(visionOS)
    private let top_spacing: CGFloat = 48
    private let bottom_spacing: CGFloat = 0//40
    #else
    private let top_spacing: CGFloat = 96
    private let bottom_spacing: CGFloat = 44
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.entity_items.count > 0
            {
                ScrollView
                {
                    Spacer(minLength: top_spacing)
                    
                    LazyVGrid(columns: columns, spacing: card_spacing)
                    {
                        ForEach(base_stc.entity_items)
                        { item in
                            GlassBoxCard(
                                title: item.name,
                                entity: item.entity.clone(recursive: true),
                                vertical_repostion: true,
                            )
                            .frame(height: card_height)
                            .onTapGesture
                            {
                                on_select(item.name)
                                is_presented = false
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Entities", systemImage: "cube")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: "Select Entity", plain: false))
        #if os(macOS)
        .frame(minWidth: 420, maxWidth: 600, minHeight: 480, maxHeight: 600)
        //.frame(width: 420, height: 480)
        #elseif os(iOS)
        .background(.white)
        #elseif os(visionOS)
        .frame(width: 600, height: 600)
        #endif
    }
}

#Preview
{
    EntitySelectorView(is_presented: .constant(true), on_select: { _ in })
}
