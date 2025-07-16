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
    @Binding var code: String
    @Binding var is_presented: Bool
    
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
    let label: String
    
    var body: some View
    {
        #if os(macOS) || os(visionOS)
        VStack(spacing: 0)
        {
            CodeView(text: $code)
                .onChange(of: code)
                { _, _ in
                    document_handler.document_update_listings()
                }
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: label))
        .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #else
        if horizontal_size_class != .compact
        {
            VStack(spacing: 0)
            {
                CodeView(text: $code)
                    .onChange(of: code)
                    { _, _ in
                        document_handler.document_update_listings()
                    }
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: label))
            .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        }
        else
        {
            VStack(spacing: 0)
            {
                CodeView(text: $code)
                    .onChange(of: code)
                    { _, _ in
                        document_handler.document_update_listings()
                    }
            }
            .modifier(SheetCaption(is_presented: $is_presented, label: label))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #endif
    }
}

#Preview
{
    ListingView(code: .constant(""), is_presented: .constant(true), label: "code")
}
