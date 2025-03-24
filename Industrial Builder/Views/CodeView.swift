//
//  CodeView.swift
//  Industrial Builder
//
//  Created by Artem on 22.03.2025.
//

import SwiftUI
import CodeEditorView
import LanguageSupport

struct CodeView: View
{
    @Binding var text: String
    
    @State private var position: CodeEditor.Position = CodeEditor.Position()
    @State private var messages: Set<TextLocated<Message>> = Set()
    
    @State private var show_minimap: Bool = true
    @State private var wrap_text: Bool = true
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View
    {
        CodeEditor(text: $text, position: $position, messages: $messages, language: .swift())
            .environment(\.codeEditorTheme, colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
            .environment(\.codeEditorLayoutConfiguration,
                          CodeEditor.LayoutConfiguration(showMinimap: show_minimap, wrapText: wrap_text))
    }
}

#Preview
{
    CodeView(text: .constant("\"print(\"UwU\")"))
}
