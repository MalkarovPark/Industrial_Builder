//
//  Industrial_BuilderApp.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 06.10.2023.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct Industrial_BuilderApp: App
{
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene
    {
        DocumentGroup(newDocument: STCDocument())
        { file in
            ContentView(document: file.$document)
        }
        .commands
        {
            SidebarCommands() //Sidebar control items for view menu item
            
            /*CommandGroup(after: CommandGroupPlacement.sidebar) //View commands for view menu item
            {
                Divider()
                Button("Reset Camera")
                {
                    app_state.reset_view = true //Begin reset camera process
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(!app_state.reset_view_enabled) //Disable reset view item when camera is reseting
                Divider()
            }*/
            
            CommandMenu("Open")
            {
                Button("Editor")
                {
                    openWindow(id: "editor")
                }
            }
        }
        
        WindowGroup("Editor", id: "editor")
        {
            KinematicEditorView()
        }
    }
}
