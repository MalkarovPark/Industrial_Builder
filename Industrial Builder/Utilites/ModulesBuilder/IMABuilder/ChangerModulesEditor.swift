//
//  ChangerModulesEditor.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 18.04.2024.
//

import SwiftUI

struct ChangerModulesEditor: View
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
                
                GroupBox
                {
                    VStack(spacing: 0)
                    {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                #if os(visionOS)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                #endif
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
    ChangerModulesEditor()
}
