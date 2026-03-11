//
//  GlassTile.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

public struct GlassTile<Content: View>: View
{
    let color: Color?
    let content: Content?
    
    public init(
        color: Color? = nil,
        @ViewBuilder content: () -> Content? = { EmptyView() }
    )
    {
        self.color = color
        self.content = content()
    }
    
    public var body: some View
    {
        ZStack
        {
            if let color = color
            {
                let gradient = Gradient(stops: [
                    Gradient.Stop(color: color.opacity(0.4), location: 0.0),
                    Gradient.Stop(color: color.opacity(0.2), location: 1.0)
                ])
                
                ZStack
                {
                    Rectangle()
                        .foregroundStyle(color.opacity(0.5))
                    
                    Rectangle()
                        .foregroundStyle(gradient)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: color.opacity(0.5), radius: 16)
            }
            else
            {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 16)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: .gray.opacity(0.06), location: 0.0),
                                Gradient.Stop(color: .gray.opacity(0.04), location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview
{
    VStack(spacing: 32)
    {
        GlassTile(color: .accent)
            .frame(width: 160, height: 96)
        
        GlassTile()
            .frame(width: 160, height: 96)
    }
    .padding(32)
}
