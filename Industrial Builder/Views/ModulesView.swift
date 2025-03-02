//
//  ModulesView.swift
//  Industrial Builder
//
//  Created by Artem on 06.04.2024.
//

import SwiftUI

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
                        StandardNavigationCard(name: "Robot", count_number: base_stc.robot_modules.count, image_name: "r.square", color: .green)
                        {
                            RobotModulesView()
                        }
                        
                        StandardNavigationCard(name: "Tool", count_number: base_stc.tool_modules.count, image_name: "hammer", color: .teal)
                        {
                            ToolModulesView()
                        }
                        
                        StandardNavigationCard(name: "Part", count_number: base_stc.part_modules.count, image_name: "shippingbox", color: .indigo)
                        {
                            PartModulesView()
                        }
                        
                        StandardNavigationCard(name: "Changer", count_number: base_stc.changer_modules.count, image_name: "wand.and.rays", color: .pink)
                        {
                            ChangerModulesView()
                        }
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
