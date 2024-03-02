//
//  AppView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 11.10.2023.
//

import SwiftUI
import IndustrialKit

struct AppView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var document: STCDocument
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                Text("Robotic Complex Workspace")
                    .font(.title2)
                    .padding()
                
                LazyVGrid(columns: columns, spacing: 24)
                {
                    StandardSheetCard(name: "Robot", count_number: 0, image_name: "r.square.fill", color: .green)
                    { is_presented in
                        RobotModulesEditor(is_presented: is_presented)
                    }
                    
                    StandardSheetCard(name: "Tool", count_number: base_stc.tool_modules.count, image_name: "hammer.fill", color: .teal)
                    { is_presented in
                        ToolModulesEditor(is_presented: is_presented)
                            .onChange(of: base_stc.tool_modules)
                            { _, new_value in
                                document.tool_modules = base_stc.tool_modules
                            }
                    }
                    
                    StandardSheetCard(name: "Changer", count_number: base_stc.changer_modules.count, image_name: "wand.and.rays", color: .indigo)
                    { is_presented in
                        ChangerModulesEditor(is_presented: is_presented)
                            .onChange(of: base_stc.changer_modules)
                            { _, new_value in
                                document.changer_modules = new_value
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .modifier(WindowFramer())
    }
}

#Preview
{
    AppView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
}
