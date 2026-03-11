//
//  ModulesTile.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

struct ModulesTile: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    let on_update: () -> ()
    
    enum DeviceMode: String, CaseIterable
    {
        case internal_modules = "internal_modules"
        case external_modules = "external_modules"
        
        var title: String
        {
            switch self
            {
            case .internal_modules: "Internal Modules"
            case .external_modules: "External Modules"
            }
        }
    }
    
    var body: some View
    {
        GlassTile()
        {
            if stc.any_modules_avaliable
            {
                ScrollView
                {
                    ModuleSelector(stc: stc, on_update: on_update)
                    
                    Spacer(minLength: 52)
                }
                .overlay(alignment: .bottom)
                {
                    VStack
                    {
                        HStack
                        {
                            Text("Modules")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                                .padding(.leading, 16)
                            
                            Spacer()
                        }
                    }
                    .background(.ultraThinMaterial)
                }
            }
            else
            {
                Text("No Modules")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview
{
    ModulesTile(stc: StandardTemplateConstruct(), on_update: {})
        .frame(width: 320, height: 192)
        .padding(32)
}
