//
//  ListBorderer.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 02.03.2024.
//

import Foundation
import SwiftUI

struct ListBorderer: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
            .listStyle(.plain)
        #if os(macOS)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        #else
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        #endif
            .shadow(radius: 1)
    }
}
