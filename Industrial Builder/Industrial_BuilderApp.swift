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
