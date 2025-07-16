//
//  AppState.swift
//  Industrial Builder
//
//  Created by Artem on 28.10.2023.
//

import Foundation
import SceneKit
import SwiftUI
import IndustrialKit

// MARK: - Class for work with various application data
class AppState : ObservableObject
{
    #if os(iOS) || os(visionOS)
    @Published var settings_view_presented = false // Flag for showing setting view for iOS and iPadOS
    #endif
    
    // Pass data
    @Published var preferences_pass_mode = false
    public var robot_from = Robot()
    
    public var origin_location_flag = false
    public var origin_rotation_flag = false
    public var space_scale_flag = false
    
    // Other
    @Published var get_scene_image = false // Flag for getting a snapshot of the scene view
    
    public var previewed_object: WorkspaceObject? // Part for preview view
    public var preview_update_scene = false // Flag for update previewed part node in scene
    public var object_view_was_open = false // Flag for provide model controller for model in scene
    
    @Published var view_update_state = false // Flag for update parts view grid
    
    // MARK: - Kinematic view functions
    @Published var kinematic_preview_robot = Robot()
    
    public func prepare_robot(_ kinematic: KinematicGroup, scene: SCNScene)
    {
        // Build design robot
        kinematic_preview_robot = kinematic.type.design_robot
        
        // Connect workcell box and pointer
        kinematic_preview_robot.workcell_connect(scene: scene, name: "unit", connect_camera: false)
        kinematic_preview_robot.origin_position = (x: 100, y: 100, z: 100, r: 0, p: 0, w: 0)
        
        update_robot_kinematic(kinematic.data)
        
        kinematic_preview_robot.position = (x: 0, y: 0, z: 0, r: 0, p: 0, w: 0)
    }
    
    public func update_robot_kinematic(_ elements: [KinematicElement])
    {
        var lengths = [Float]()
        for element in elements
        {
            lengths.append(element.value)
        }
        
        guard let controller = kinematic_preview_robot.model_controller as? DesignerRobotModelController
        else
        {
            return
        }
        
        controller.transform_by_lengths(lengths)
        kinematic_preview_robot.update()
        kinematic_preview_robot.robot_location_place()
    }
    
    @Published var make_model_from_kinematic = true
    @Published var make_controller_from_kinematic = true
    @Published var kinematic_module_type_selection = 0
}

// MARK: - Service Functions
func import_text_data(from file_name: String) -> String
{
    if let file_url = Bundle.main.url(forResource: file_name, withExtension: "txt")
    {
        do
        {
            let content = try String(contentsOf: file_url, encoding: .utf8)
            return content
        }
        catch
        {
            return String()
        }
    }
    else
    {
        return String()
    }
}

func color_from_string(_ text: String) -> Color
{
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    
    for (i, char) in text.enumerated()
    {
        let value = Float(char.asciiValue ?? 0) / 255.0
        switch i % 3
        {
        case 0:
            r = CGFloat(value)
        case 1:
            g = CGFloat(value)
        case 2:
            b = CGFloat(value)
        default:
            break
        }
    }
    
    return Color(red: Double(r), green: Double(g), blue: Double(b))
}
