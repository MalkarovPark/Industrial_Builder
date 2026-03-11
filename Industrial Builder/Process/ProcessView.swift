//
//  ProcessView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

struct ProcessView: View
{
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    @Binding var document: STCDocument
    @Binding var is_presented: Bool
    
    var body: some View
    {
        NavigationStack
        {
            
        }
        #if os(macOS)
        .toolbar
        {
            ToolbarItem(placement: .cancellationAction)
            {
                Button("Dismiss")
                {
                    is_presented = false
                }
            }
        }
        #endif
    }
}

struct ProcessItemView<Content: View>: View
{
    let title: String
    let subtitle: String
    let content: () -> Content
    
    var body: some View
    {
        HStack
        {
            ZStack
            {
                content()
                    .scaledToFit()
            }
            #if os(macOS)
            .frame(width: 40, height: 40)
            #else
            .frame(width: 48, height: 48)
            #endif
            #if !os(visionOS)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            #endif
            .shadow(color: .black.opacity(0.1), radius: 6)
            //.shadow(color: .black.opacity(0.05), radius: 4)
            
            VStack(alignment: .leading)
            {
                Text(title)
                
                Text(subtitle)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .padding(.trailing, 8)
        }
        #if os(iOS)
        .padding(10)
        .glassEffect(in: .rect(cornerRadius: 16.0))
        #else
        .padding(.vertical, 8)
        #endif
        .frame(maxWidth: .infinity)
    }
}

#Preview
{
    ProcessView(document: .constant(STCDocument()), is_presented: .constant(true))
        .frame(width: 320, height: 400)
}

#Preview
{
    ProcessItemView(title: "Packages", subtitle: "None", content: {
        EmptyView()
    })
    .frame(width: 256)
}
