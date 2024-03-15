//
//  BuildView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI

struct BuildView: View
{
    @State private var targets_palette_view_presented = false
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            GroupBox//(label: Text("App"))
            {
                VStack(spacing: 0)
                {
                    Text("None")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            
            Button(action: { targets_palette_view_presented = true })
            {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 8, height: 16)
                    .padding()
                #if os(iOS)
                    .foregroundColor(false ? Color.secondary : Color.black)
                #elseif os(visionOS)
                    .foregroundColor(false ? Color.secondary : Color.primary)
                #endif
            }
            .popover(isPresented: $targets_palette_view_presented, arrowEdge: .leading)
            {
                TargetsPalette(is_presented: $targets_palette_view_presented)
            }
            .padding(.trailing)
        }
    }
}

struct TargetsPalette: View
{
    @Binding var is_presented: Bool
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Palette")
                .padding()
        }
        #if os(macOS) || os(visionOS)
        .frame(width: 320, height: 320)
        #endif
    }
}

#Preview
{
    BuildView()
}

#Preview
{
    TargetsPalette(is_presented: .constant(true))
}
