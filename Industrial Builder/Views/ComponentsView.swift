//
//  ComponentsView.swift
//  Industrial Builder
//
//  Created by Artem on 25.10.2023.
//

import SwiftUI

struct ComponentsView: View
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
                        StandardNavigationCard(name: "Scenes", count_number: base_stc.scenes.count, image_name: "cube", color: .green)
                        {
                            ScenesListView()
                        }
                        
                        StandardNavigationCard(name: "Images", count_number: base_stc.images.count, image_name: "photo", color: .teal)
                        {
                            ImagesListView()
                        }
                        
                        StandardNavigationCard(name: "Listings", count_number: base_stc.listings.count, image_name: "scroll", color: .indigo)
                        {
                            ListingsListView()
                        }
                        
                        StandardNavigationCard(name: "Kinematics", count_number: base_stc.kinematic_groups.count, image_name: "point.3.connected.trianglepath.dotted", color: .purple)
                        {
                            KinematicsListView()
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
    ComponentsView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
