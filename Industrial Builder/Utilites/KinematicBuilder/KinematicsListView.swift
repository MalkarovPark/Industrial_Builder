//
//  KinematicsListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 25.10.2023.
//

import SwiftUI

struct KinematicsListView: View
{
    @State var kinematics = [PortalGroupMake(name: "Portal"), KinematicGroup(name: "6DOF")]
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(kinematics)
                    { kinematic in
                        ComponentCard(name: kinematic.name, image_name: "gearshape.2.fill", color: .gray)
                        {is_presented in
                            KinematicEditorView(is_presented: is_presented)
                        }
                    }
                }
                .padding(20)
            }
        }
        .toolbar
        {
            Button (action: {  })
            {
                Label("Add Kinematic", systemImage: "plus")
            }
        }
        .modifier(WindowFramer())
    }
}

#Preview
{
    KinematicsListView()
}
