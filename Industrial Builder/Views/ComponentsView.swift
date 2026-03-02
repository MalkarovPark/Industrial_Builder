//
//  ComponentsView.swift
//  Industrial Builder
//
//  Created by Artem on 25.10.2023.
//

import SwiftUI
import IndustrialKitUI

struct ComponentsView: View
{
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        NavigationStack
        {
            ScrollView(.vertical)
            {
                VStack(spacing: 0)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        NavigationLink(destination: EntityListView())
                        {
                            BoxCard(title: "Entities", subtitle: numeral_endings(base_stc.entity_items.count, word: "item"), color: .green, symbol_name: "cube", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ImageListView())
                        {
                            BoxCard(title: "Images", subtitle: numeral_endings(base_stc.image_items.count, word: "item"), color: .teal, symbol_name: "photo", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ListingListView())
                        {
                            BoxCard(title: "Listings", subtitle: numeral_endings(base_stc.listing_items.count, word: "item"), color: .indigo, symbol_name: "scroll", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                    }
                    .padding(20)
                }
            }
        }
    }
}

#Preview
{
    ComponentsView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
