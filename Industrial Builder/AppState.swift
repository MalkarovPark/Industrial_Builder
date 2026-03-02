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
    //public var robot_from = Robot()
    
    public var origin_location_flag = false
    public var origin_rotation_flag = false
    public var space_scale_flag = false
    
    // Other
    @Published var get_scene_image = false // Flag for getting a snapshot of the scene view
    
    public var previewed_object: WorkspaceObject? // Part for preview view
    public var preview_update_scene = false // Flag for update previewed part node in scene
    public var object_view_was_open = false // Flag for provide model controller for model in scene
    
    @Published var view_update_state = false // Flag for update parts view grid
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
