//
//  KinematicInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 05.11.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

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
                        KinematicElementView(element: $elements[index])
                        {
                            app_state.update_robot_kinematic(elements)
                            document_handler.document_update_kinematics()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .modifier(ListBorderer())
            #if !os(visionOS)
            .padding([.horizontal, .top])
            #else
            .padding([.horizontal])
            #endif
            
            PositionControl(position: $app_state.kinematic_preview_robot.pointer_position, scale: $app_state.kinematic_preview_robot.space_scale)
        }
        #if os(visionOS)
        .frame(width: 400)
        #endif
        .onAppear
        {
            app_state.update_robot_kinematic(elements)
        }
    }
}

struct KinematicElementView: View
{
    @Binding var element: KinematicElement
    
    var on_update: () -> Void
    
    var body: some View
    {
        HStack(spacing: 12)
        {
            Text(element.name)
            TextField("0", value: $element.value, formatter: NumberFormatter())
            #if os(macOS)
            .textFieldStyle(.squareBorder)
            #endif
            Stepper("", value: $element.value)
                .labelsHidden()
        }
        .onChange(of: element.value)
        { _, _ in
            on_update()
        }
    }
}

#Preview
{
    KinematicInspectorView(elements: .constant([KinematicElement(name: "L1", value: 160.0)]))
        .frame(width: 256, height: 480)
        .environmentObject(AppState())
        
}
