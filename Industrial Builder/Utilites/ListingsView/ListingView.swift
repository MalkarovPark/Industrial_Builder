//
//  ListingView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI

struct ListingView: View
{
    @Binding var code: String
    @Binding var is_presented: Bool
    
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    let label: String
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical)
            {
                Spacer()
                TextEditor(text: $code)
                    .font(.custom("Menlo", size: 12))
                    .onChange(of: code)
                    { _, _ in
                        document_handler.document_update_listings()
                    }
            }
        }
        .modifier(Caption(is_presented: $is_presented, label: label))
        #if os(macOS)
        .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}

#Preview
{
    ListingView(code: .constant(""), is_presented: .constant(true), label: "code")
}
