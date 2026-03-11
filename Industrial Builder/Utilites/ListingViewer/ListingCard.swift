//
//  ListingCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

struct ListingCard<Content: View>: View
{
    let listing_item: ListingItem
    
    let content: (_ isPresented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var hovered = false
    
    var body: some View
    {
        Button { is_presented.toggle() }
        label:
        {
            ZStack
            {
                Rectangle()
                #if !os(visionOS)
                    .foregroundStyle(.white)
                #else
                    .foregroundStyle(.black.opacity(0.25))
                #endif
                    .overlay(alignment: .topLeading)
                {
                    Text(listing_item.text)
                    #if os(macOS)
                        .font(.custom("Menlo", size: 10))
                    #else
                        .font(.custom("Menlo", size: 14))
                    #endif
                        .foregroundStyle(.secondary)
                }
                .overlay(alignment: .bottomLeading)
                {
                    Text(listing_item.name)
                        .padding(8)
                        .background
                        {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .foregroundStyle(.thinMaterial)
                        }
                        .padding(8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .offset(y: hovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .background
        {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .blur(radius: 16)
                .opacity(0.2)
        }
        .frame(height: 192)
        .onHover
        { hovered in
            withAnimation(.easeInOut(duration: 0.2))
            {
                self.hovered = hovered
            }
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .contextMenu
        {
            Button(role: .destructive, action: delete_listing)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func delete_listing()
    {
        base_stc.listing_items.removeAll { $0 == listing_item }
        document_handler.document_update_listings()
    }
}

#Preview
{
    ListingCard(listing_item: ListingItem(name: "Code", text: ""))
    { _ in
        EmptyView()
    }
}
