//
//  ComponentsView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 25.10.2023.
//

import SwiftUI

struct ComponentsView: View
{
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var document: STCDocument
    
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
                        StandardNavigationCard(name: "Models", count_number: base_stc.models_nodes.count, image_name: "cube", color: .green)
                        {
                            ModelsListView()
                        }
                        
                        StandardNavigationCard(name: "Kinematics", count_number: base_stc.kinematic_groups.count, image_name: "point.3.connected.trianglepath.dotted", color: .teal)
                        {
                            KinematicsListView()
                        }
                        .onChange(of: base_stc.kinematic_groups)
                        { _, new_value in
                            document.kinematic_groups = new_value
                        }
                        .onChange(of: app_state.document_notify)
                        { _, _ in
                            document.kinematic_groups = base_stc.kinematic_groups
                        }
                        
                        StandardNavigationCard(name: "Changer", count_number: base_stc.changer_modules.count, image_name: "wand.and.rays", color: .indigo)
                        {
                            ChangerModulesEditor(document: $document)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .modifier(WindowFramer())
    }
}

#Preview
{
    ComponentsView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
