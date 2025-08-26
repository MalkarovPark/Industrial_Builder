//
//  ComponentsView.swift
//  Industrial Builder
//
//  Created by Artem on 25.10.2023.
//

import SwiftUI
import IndustrialKitUI

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
                        NavigationLink(destination: ScenesListView())
                        {
                            BoxCard(title: "Scenes", subtitle: numeral_endings(base_stc.scenes.count, word: "item"), color: .green, image_name: "cube", image_size: 80)
                        }
                        .buttonStyle(.borderless)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ImagesListView())
                        {
                            BoxCard(title: "Images", subtitle: numeral_endings(base_stc.images.count, word: "item"), color: .teal, image_name: "photo", image_size: 80)
                        }
                        .buttonStyle(.borderless)
                        .frame(height: 128)
                        
                        NavigationLink(destination: ListingsListView())
                        {
                            BoxCard(title: "Listings", subtitle: numeral_endings(base_stc.listings.count, word: "item"), color: .indigo, image_name: "scroll", image_size: 80)
                        }
                        .buttonStyle(.borderless)
                        .frame(height: 128)
                        
                        NavigationLink(destination: KinematicsListView())
                        {
                            BoxCard(title: "Kinematics", subtitle: numeral_endings(base_stc.kinematic_groups.count, word: "item"), color: .purple, image_name: "point.3.connected.trianglepath.dotted", image_size: 80)
                        }
                        .buttonStyle(.borderless)
                        .frame(height: 128)
                    }
                    .padding(20)
                }
            }
        }
    }
}

func numeral_endings(_ count: Int, word: String) -> String
{
    count == 1 ? "\(count) \(word)" : "\(count) \(word)s"
}

#Preview
{
    ComponentsView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
