//
//  KinematicInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 05.11.2024.
//

import SwiftUI
import IndustrialKit

struct KinematicInspectorView: View
{
    @Binding var elements: [KinematicElement]
    
    @State private var expanded = [false, false, false]
    
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            List
            {
                Section("Parameters")
                {
                    ForEach(elements.indices, id: \.self)
                    { index in
                        HStack(spacing: 12)
                        {
                            Text(elements[index].name)
                            TextField("0", value: $elements[index].value, formatter: NumberFormatter())
                            #if os(macOS)
                                .textFieldStyle(.squareBorder)
                            #endif
                            Stepper("", value: $elements[index].value)
                                .labelsHidden()
                        }
                    }
                }
            }
            #if os(macOS)
            .listStyle(.plain)
            #endif
            .modifier(ViewBorderer())
            #if !os(visionOS)
            .padding([.horizontal, .top])
            #endif
            
            PositionControl(location: $app_state.kinematic_preview_robot.pointer_location, rotation: $app_state.kinematic_preview_robot.pointer_rotation, scale: $app_state.kinematic_preview_robot.space_scale)
        }
        #if os(visionOS)
        .frame(width: 400)
        #endif
        .onAppear
        {
            app_state.update_robot_kinematic(elements)
        }
        .onChange(of: elements)
        { _, new_value in
            app_state.update_robot_kinematic(new_value)
            document_handler.document_update_kinematics()
        }
    }
}

#Preview
{
    KinematicInspectorView(elements: .constant([KinematicElement(name: "L1", value: 160.0)]))
        .frame(width: 256, height: 480)
        .environmentObject(AppState())
        
}
