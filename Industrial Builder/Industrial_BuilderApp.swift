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
        //DocumentGroupAlt(newDocument: STCDocument())
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

// MARK: - DocumentGroupAlt
public struct DocumentGroupAlt<Document, Content>: Scene
where Document: FileDocument, Content: View {
    
    private let newDocument: () -> Document
    private let content: (FileDocumentConfiguration<Document>) -> Content
    
    public init(
        newDocument: @autoclosure @escaping () -> Document,
        @ViewBuilder content: @escaping (FileDocumentConfiguration<Document>) -> Content
    ) {
        self.newDocument = newDocument
        self.content = content
    }
    
    public var body: some Scene {
        WindowGroup {
            DocumentView(newDocument: newDocument, content: content)
        }
    }
}

// MARK: - DocumentView
struct DocumentView<Document: FileDocument, Content: View>: View {
    @State private var document: Document
    @State private var fileURL: URL? = nil
    
    private let content: (FileDocumentConfiguration<Document>) -> Content
    
    init(newDocument: @escaping () -> Document,
         content: @escaping (FileDocumentConfiguration<Document>) -> Content) {
        _document = State(initialValue: newDocument())
        self.content = content
    }
    
    var body: some View {
        content(
            FileDocumentConfiguration(
                document: $document,
                fileURL: fileURL
            )
        )
    }
}

// MARK: - FileDocumentConfiguration
public struct FileDocumentConfiguration<Document: FileDocument> {
    @Binding public var document: Document   // <-- @Binding!
    public var fileURL: URL?
    
    public init(document: Binding<Document>, fileURL: URL?) {
        self._document = document
        self.fileURL = fileURL
    }
}
