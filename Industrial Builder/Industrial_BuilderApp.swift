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
            /*CommandGroup(after: CommandGroupPlacement.sidebar) // View commands for view menu item
            {
                Divider()
                Button("Reset Camera")
                {
                    
                }
                .keyboardShortcut("0", modifiers: .command)
                Divider()
            }*/
            
            SidebarCommands() // Sidebar control items for view menu item
            
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
        DocumentGroupLaunchScene("Industrial Builder")
        {
            NewDocumentButton("New STC")
        }
        background:
        {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("#8E81DD"), Color("#AA9FEF")]),
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
        #endif
    }
}

// MARK: - Arrow edge positions
#if os(macOS)
let default_popover_edge: Edge = .top
#else
let default_popover_edge: Edge = .bottom
#endif

#if os(macOS)
let default_popover_edge_inverted: Edge = .bottom
#else
let default_popover_edge_inverted: Edge = .top
#endif
