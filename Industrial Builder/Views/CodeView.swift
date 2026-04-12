//
//  CodeView.swift
//  Industrial Builder
//
//  Created by Artem on 22.03.2025.
//

import SwiftUI
#if !os(visionOS)
import CodeEditorView
#endif
import LanguageSupport

public struct CodeView: View
{
    let language: LanguageConfiguration
    @Binding var text: String
    
    #if !os(visionOS)
    @State private var position: CodeEditor.Position = CodeEditor.Position()
    #endif
    @State private var messages: Set<TextLocated<Message>> = Set()
    
    @State private var show_minimap: Bool = true
    @State private var wrap_text: Bool = true
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    public init
    (
        text: Binding<String>,
        language: LanguageConfiguration = .swift()
    )
    {
        self._text = text
        self.language = language
    }
    
    public var body: some View
    {
        #if !os(visionOS)
        CodeEditor(text: $text, position: $position, messages: $messages, language: language)
            .environment(\.codeEditorTheme, colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
            .environment(\.codeEditorLayoutConfiguration,
                          CodeEditor.LayoutConfiguration(showMinimap: show_minimap, wrapText: wrap_text))
        #else
        TextEditor(text: $text)
            .textFieldStyle(.plain)
            .font(.custom("Menlo", size: 16))
        #endif
        
        /*if !code_plain_text_representation
        {
            CodeEditor(text: $text, position: $position, messages: $messages, language: .swift())
                .environment(\.codeEditorTheme, colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
                .environment(\.codeEditorLayoutConfiguration,
                              CodeEditor.LayoutConfiguration(showMinimap: show_minimap, wrapText: wrap_text))
        }
        else
        {
            VStack
            {
                TextEditor(text: $text)
                .textFieldStyle(.plain)
                .font(.custom("Menlo", size: 12))
            }
        }*/
    }
}

#Preview
{
    CodeView(text: .constant("\"print(\"output\")"))
}
