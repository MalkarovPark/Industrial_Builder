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
    //@Environment(\.openWindow) var openWindow
    @StateObject var app_state = AppState() //Init application state
    
    var body: some Scene
    {
        DocumentGroup(newDocument: STCDocument())
        { file in
            ContentView(document: file.$document)
        }
        .environmentObject(app_state)
        .commands
        {
            CommandGroup(after: CommandGroupPlacement.sidebar) //View commands for view menu item
            {
                Divider()
                Button("Reset Camera")
                {
                    app_state.reset_view = true //Begin reset camera process
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(!app_state.reset_view_enabled) //Disable reset view item when camera is reseting
                Divider()
            }
            
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
        
        /*WindowGroup("Editor", id: "editor")
        {
            KinematicEditorView()
        }*/
    }
}
