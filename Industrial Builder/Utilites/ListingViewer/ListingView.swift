//
//  ListingView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct ListingView: View
{
    @Binding var is_presented: Bool
    
    @ObservedObject var listing_item: ListingItem
    
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    var body: some View
    {
        let code_text = Binding(
            get: { listing_item.text },
            set:
                { new_value in
                    listing_item.text = new_value
                    
                    document_handler.document_update_listings()//on_update()
                }
        )
        
        #if os(macOS) || os(visionOS)
        VStack(spacing: 0)
        {
            CodeView(text: code_text)
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: listing_item.name))
        .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #else
        if horizontal_size_class != .compact
        {
            VStack(spacing: 0)
            {
                CodeView(text: code_text)
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: listing_item.name))
            .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        }
        else
        {
            VStack(spacing: 0)
            {
                CodeView(text: code_text)
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: listing_item.name))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #endif
    }
}

#Preview
{
    ListingView(is_presented: .constant(true), listing_item: ListingItem(name: "Code", text: "import Foundation"))
}
