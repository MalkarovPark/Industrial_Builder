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
    
    var body: some View
    {
        GlassTile(color: .accentColor)
        {
            ScrollView
            {
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
                    .font(.title3)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(.white)
                
                Spacer(minLength: 52)
            }
            .overlay(alignment: .bottom)
            {
                HStack
                {
                    Text("Description")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
                .background(.ultraThinMaterial)
            }
        }
    }
}

#Preview
{
    DescriptionTile(stc: StandardTemplateConstruct(), on_update: {})
        .frame(width: 320, height: 224)
        .padding(32)
}
