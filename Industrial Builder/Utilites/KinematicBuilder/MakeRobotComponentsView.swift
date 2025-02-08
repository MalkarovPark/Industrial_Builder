//
//  MakeRobotComponentsView.swift
//  Industrial Builder
//
//  Created by Artem on 05.11.2024.
//

import SwiftUI
import SceneKit
import IndustrialKit

struct MakeRobotComponentsView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var group: KinematicGroup
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            VStack(alignment: .trailing, spacing: 0)
            {
                Toggle(isOn: $app_state.make_model_from_kinematic)
                {
                    Text("Visual Model")
                }
                .toggleStyle(.switch)
                .padding(.bottom)
                
                Toggle(isOn: $app_state.make_controller_from_kinematic)
                {
                    Text("Controller")
                }
                .toggleStyle(.switch)
                .padding(.bottom)
            }
            
            Menu("Export to...")
            {
                if base_stc.robot_modules.count > 0
                {
                    ForEach(base_stc.robot_modules_names, id: \.self)
                    { name in
                        Button(name)
                        {
                            base_stc.make_copmponents_from_kinematic(
                                group: group,
                                to: name,
                                node: app_state.kinematic_preview_robot.node ?? SCNNode(),
                                make_controller: app_state.make_controller_from_kinematic, make_model: app_state.make_model_from_kinematic,
                                robots_update_function: { document_handler.document_update_robots() },
                                scenes_update_function: { document_handler.document_update_scenes() }
                            )
                        }
                    }
                    
                    Divider()
                }
                
                Button("Separated Components")
                {
                    base_stc.make_copmponents_from_kinematic(
                        group: group, node: app_state.kinematic_preview_robot.node ?? SCNNode(),
                        make_controller: app_state.make_controller_from_kinematic, make_model: app_state.make_model_from_kinematic,
                        listings_update_function: { document_handler.document_update_listings() },
                        scenes_update_function: { document_handler.document_update_scenes() }
                    )
                }
            }
            #if os(macOS)
            .menuStyle(.borderedButton)
            #elseif os(iOS)
            .modifier(PickerBorderer())
            #endif
            .disabled((base_stc.robot_modules.isEmpty) && (!app_state.make_model_from_kinematic && !app_state.make_controller_from_kinematic))
        }
        .padding()
    }
}

#Preview
{
    MakeRobotComponentsView(group: .constant(KinematicGroup()))
        .frame(width: 256)
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(AppState())
}
