//
//  Industrial_BuilderApp.swift
//  Industrial Builder
//
//  Created by Artem on 06.10.2023.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct Industrial_BuilderApp: App
{
    //@Environment(\.openWindow) var openWindow
    @StateObject var app_state = AppState() //Init application state
    
    var body: some Scene
    {
        DocumentGroup(newDocument: STCDocument())
        { file in
            ContentView(document: file.$document, document_url: file.fileURL)
                .environmentObject(app_state)
        }
        //.environmentObject(app_state)
        .commands
        {
            /*CommandGroup(after: CommandGroupPlacement.sidebar) //View commands for view menu item
            {
                Divider()
                Button("Reset Camera")
                {
                    
                }
                .keyboardShortcut("0", modifiers: .command)
                Divider()
            }*/
            
            SidebarCommands() //Sidebar control items for view menu item
            
            /*CommandMenu("Open")
            {
                Button("Editor")
                {
                    openWindow(id: "editor")
                }
                .keyboardShortcut("E", modifiers: .command)
            }*/
        }
        
        #if !os(macOS)
        if #available(iOS 18.0, visionOS 2.0, *)
        {
            DocumentGroupLaunchScene("Industrial Builder")
            {
                NewDocumentButton("New STC")
            }
        background:
            {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#8E81DD"), Color(hex: "#AA9FEF")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .ignoresSafeArea()
            }
        overlayAccessoryView:
            { _ in
                //AccessoryView()
            }
        }
        #endif
    }
}

//MARK: - Arrow edge positions
#if os(macOS)
let default_popover_edge: Edge = .top
#else
let default_popover_edge: Edge = .bottom
#endif

//MARK: - Color by hex
extension Color
{
    /**
     Initializes a `Color` instance from a HEX string.
     
     - Parameters:
        - hex: A string representing the HEX color. Supported formats: `#RRGGBB`, `#RRGGBBAA`, `RRGGBB`, `RRGGBBAA`.
        - alpha: An optional alpha value between 0 and 1. Defaults to `1.0` (fully opaque). If the HEX string includes alpha, this parameter is ignored.
     
     - Returns: A `Color` instance or a fallback to `clear` if the HEX string is invalid.
     */
    init(hex: String, alpha: Double = 1.0)
    {
        // Remove any leading "#" and ensure proper casing
        let sanitizedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()
        
        // Convert HEX string to UInt64
        var hexValue: UInt64 = 0
        guard Scanner(string: sanitizedHex).scanHexInt64(&hexValue)
        else
        {
            self = .clear // Fallback to a transparent color if invalid
            return
        }
        
        let red, green, blue, computedAlpha: Double
        
        switch sanitizedHex.count
        {
        case 6: // #RRGGBB
            red = Double((hexValue >> 16) & 0xFF) / 255.0
            green = Double((hexValue >> 8) & 0xFF) / 255.0
            blue = Double(hexValue & 0xFF) / 255.0
            computedAlpha = alpha
        case 8: // #RRGGBBAA
            red = Double((hexValue >> 24) & 0xFF) / 255.0
            green = Double((hexValue >> 16) & 0xFF) / 255.0
            blue = Double((hexValue >> 8) & 0xFF) / 255.0
            computedAlpha = Double(hexValue & 0xFF) / 255.0
        default:
            self = .clear // Fallback for invalid length
            return
        }
        
        self = Color(
            red: red,
            green: green,
            blue: blue,
            opacity: computedAlpha
        )
    }
}
