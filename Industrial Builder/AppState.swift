//
//  AppState.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 28.10.2023.
//

import Foundation
import SceneKit
import SwiftUI
import IndustrialKit

//MARK: - Class for work with various application data
class AppState : ObservableObject
{
    //Commands
    @Published var reset_view = false //Flag for return camera position to default in scene views
    @Published var reset_view_enabled = true //Reset menu item availability flag
    
    #if os(iOS) || os(visionOS)
    @Published var settings_view_presented = false //Flag for showing setting view for iOS and iPadOS
    #endif
    
    //Pass data
    @Published var preferences_pass_mode = false
    public var robot_from = Robot()
    
    public var origin_location_flag = false
    public var origin_rotation_flag = false
    public var space_scale_flag = false
    
    //Other
    @Published var get_scene_image = false //Flag for getting a snapshot of the scene view
    
    public var previewed_object: WorkspaceObject? //Part for preview view
    public var preview_update_scene = false //Flag for update previewed part node in scene
    public var object_view_was_open = false //Flag for provide model controller for model in scene
    
    @Published var view_update_state = false //Flag for update parts view grid
    
    //MARK: - Visual functions
    func reset_camera_view_position(locataion: SCNVector3, rotation: SCNVector4, view: SCNView)
    {
        if reset_view && reset_view_enabled
        {
            let reset_action = SCNAction.group([SCNAction.move(to: locataion, duration: 0.5), SCNAction.rotate(toAxisAngle: rotation, duration: 0.5)])
            reset_view = false
            reset_view_enabled = false
            
            view.defaultCameraController.pointOfView?.runAction(
                reset_action, completionHandler: {
                    self.reset_view_enabled = true
                })
        }
    }
    
    //MARK: - Register colors
    public var register_colors = Array(repeating: Color.clear, count: 256)
}

//MARK - Control modifier
struct MenuHandlingModifier: ViewModifier
{
    @EnvironmentObject var app_state: AppState
    
    @Binding var performed: Bool
    
    let toggle_perform: () -> ()
    let stop_perform: () -> ()
    
    public func body(content: Content) -> some View
    {
        content
            /*.onChange(of: app_state.run_command)
            { _, _ in
                toggle_perform()
            }
            .onChange(of: app_state.stop_command)
            { _, _ in
                stop_perform()
            }*/
            .onAppear
            {
                app_state.reset_view = false
                app_state.reset_view_enabled = true
            }
    }
}
