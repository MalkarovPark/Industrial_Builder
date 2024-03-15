//
//  NoView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 15.03.2024.
//

import SwiftUI

struct NoView: View
{
    let label: String
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text(label)
                .font(.largeTitle)
            #if os(macOS)
                .foregroundColor(Color(NSColor.quaternaryLabelColor))
            #else
                .foregroundColor(Color(UIColor.quaternaryLabel))
            #endif
                .padding(16)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.6)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, minHeight: 240)
    }
}

#Preview
{
    NoView(label: "No")
}
