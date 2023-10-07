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
    var body: some Scene
    {
        DocumentGroup(newDocument: Industrial_BuilderDocument())
        { file in
            ContentView(document: file.$document)
        }
    }
}
