//
//  ModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI
import IndustrialKitUI

struct ModulesView: View
{
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        NavigationStack
        {
            ScrollView(.vertical)
            {
                VStack(spacing: 0)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        NavigationLink(destination: RobotModulesView())
                        {
                            BoxCard(title: "Robot", subtitle: numeral_endings(base_stc.robot_modules.count, word: "item"), color: .green, symbol_name: "r.square", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ToolModulesView())
                        {
                            BoxCard(title: "Tool", subtitle: numeral_endings(base_stc.tool_modules.count, word: "item"), color: .teal, symbol_name: "hammer", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                        
                        NavigationLink(destination: PartModulesView())
                        {
                            BoxCard(title: "Part", subtitle: numeral_endings(base_stc.part_modules.count, word: "item"), color: .indigo, symbol_name: "shippingbox", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ChangerModulesView())
                        {
                            BoxCard(title: "Changer", subtitle: numeral_endings(base_stc.changer_modules.count, word: "item"), color: .pink, symbol_name: "wand.and.rays", symbol_size: 80)
                        }
                        .buttonStyle(.plain)
                        .frame(height: 128)
                    }
                    .padding(20)
                }
            }
        }
    }
}

#Preview
{
    ModulesView()
}
