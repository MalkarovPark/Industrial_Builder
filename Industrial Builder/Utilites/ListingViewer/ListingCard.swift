//
//  ListingCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

import IndustrialKit

struct ListingCard<Content: View>: View
{
    let listing_item: ListingItem
    
    let content: (_ isPresented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_renaming: Bool = false
    @State private var new_name: String = String()
    @FocusState private var is_focused: Bool
    
    @State private var hovered = false
    
    var body: some View
    {
        Button
        {
            is_renaming = false
            is_presented.toggle()
        }
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
                    HStack
                    {
                        if !is_renaming
                        {
                            VStack(alignment: .leading)
                            {
                                Text(listing_item.name)
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 4)
                            }
                            .padding(.horizontal, 8)
                            .padding(.trailing, 4)
                        }
                        else
                        {
                            VStack(alignment: .leading)
                            {
                                HStack
                                {
                                    #if os(macOS)
                                    TextField("Name", text: $new_name)
                                        .textFieldStyle(.roundedBorder)
                                        .focused($is_focused)
                                        .labelsHidden()
                                        .padding()
                                        .onSubmit
                                        {
                                            on_rename(new_name)
                                            is_renaming = false
                                        }
                                        .onExitCommand
                                        {
                                            is_renaming = false
                                        }
                                    #else
                                    TextField(
                                        "Name",
                                        text: $new_name, onCommit:
                                            {
                                                on_rename(new_name)
                                                is_renaming = false
                                            }
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    .focused($is_focused)
                                    .labelsHidden()
                                    .padding()
                                    #endif
                                }
                            }
                        }
                    }
                    #if !os(visionOS)
                    .background(.bar)
                    #else
                    .background(.thinMaterial)
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(8)
                    .onChange(of: is_renaming)
                    { _, new_value in
                        is_focused = new_value
                        new_name = listing_item.name
                    }
                    .onChange(of: is_focused)
                    { _, new_value in
                        if !new_value
                        {
                            is_renaming = false
                        }
                    }
                    /*Text(image_item.name)
                        .padding(8)
                        .background
                        {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .foregroundStyle(.thinMaterial)
                        }
                        .padding(8)*/
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
            RenameButton()
                .renameAction
            {
                withAnimation
                {
                    is_renaming = true
                }
            }
            
            Button(role: .destructive, action: delete_listing)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func on_rename(_ new_name: String)
    {
        if !new_name.isEmpty
        {
            let unique_name = unique_name(
                for: new_name,
                in: base_stc.listing_item_names.filter { $0 != listing_item.name } //base_stc.listing_items.map { $0.name }.filter { $0 != listing_item.name }
            )
            
            if listing_item.name != unique_name
            {
                listing_item.name = unique_name
                document_handler.document_update_listings()
            }
        }
        
        is_renaming = false
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
