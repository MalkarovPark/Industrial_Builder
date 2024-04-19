//
//  RobotModulesEditor.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI
import IndustrialKit

struct RobotsModulesEditor: View
{
    @State private var names = [String]()
    @State private var selected_name = String()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 0)
            {
                ModulesListView(names: $names, selected_name: $selected_name)
                { name in
                    names.append(name)
                }
                remove_module:
                {
                    names.remove(at: names.firstIndex(of: selected_name)!)
                }
                
                VStack(spacing: 0)
                {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(ListBorderer())
            }
            .padding()
        }
        .modifier(SheetFramer())
    }
    
    private func remove_part_model()
    {
        //base_stc.remove_selected_tool_module()
        //base_stc.deselect_tool_module()
    }
}

#Preview
{
    RobotsModulesEditor()
}
