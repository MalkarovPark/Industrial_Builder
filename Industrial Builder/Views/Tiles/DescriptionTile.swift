//
//  DescriptionTile.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

struct DescriptionTile: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    let on_update: () -> ()
    
    @FocusState private var is_focused: Bool
    
    var body: some View
    {
        GlassTile(color: Color(hex: "8E75DE"))//"A393EB"))//"7A57D1"))
        {
            ScrollView
            {
                #if os(macOS)
                Spacer(minLength: 10)
                #endif
                
                let description = Binding(
                    get: { stc.package_info.description },
                    set:
                        { new_value in
                            stc.package_info.description = new_value
                            
                            on_update()
                        }
                )
                
                TextEditor(text: description)
                    .textEditorStyle(.plain)
                    .font(.system(size: 16))
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(.white)
                    .focused($is_focused)
                    .onKeyPress(.escape)
                    {
                        is_focused = false
                        return .handled
                    }
                
                Spacer(minLength: 52)
            }
            .overlay(alignment: .center)
            {
                if stc.package_info.description.isEmpty && !is_focused
                {
                    Text("Description")
                        .font(.system(size: 32, design: .rounded))
                        .foregroundStyle(Color(hex: "8E75DE"))
                        .brightness(-0.05)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture { is_focused = true }
                }
            }
            .background(alignment: .bottomTrailing)
            {
                if !stc.package_info.description.isEmpty || is_focused
                {
                    Image(systemName: "info")
                        .font(.system(size: 20))
                        .frame(width: 16, height: 16)
                        .padding(6)
                        .foregroundStyle(Color(hex: "8E75DE"))
                        .brightness(-0.05)
                        .padding(10)
                }
            }
            .onHover
            { hovered in
                if !hovered
                {
                    is_focused = false
                }
            }
            .animation(.easeInOut(duration: 0.1), value: is_focused)
        }
    }
}

#Preview
{
    DescriptionTile(stc: StandardTemplateConstruct(), on_update: {})
        .frame(width: 320, height: 224)
        .padding(32)
}
