//
//  Framers.swift
//  Industrial Builder
//
//  Created by Artem on 09.03.2024.
//

import Foundation
import SwiftUI

struct WindowFramer: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
        #if os(macOS)
            .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600) //Window sizes for macOS
        #else
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SheetFramer: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
        #if os(macOS)
            .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #elseif os(visionOS)
            .frame(width: 512, height: 512)
        #endif
    }
}

struct TextFrame: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
            .frame(minHeight: 64)
        #if os(macOS)
            .shadow(radius: 1)
        #endif
    }
}
