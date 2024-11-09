//
//  StandardTemplateConstruct.swift
//  Industrial Builder
//
//  Created by Artem on 16.10.2023.
//

import Foundation
import SwiftUI
import SceneKit
import IndustrialKit

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package_info = STCPackageInfo()
    
    init()
    {
        //make_preview()
        //make_contents()
    }
    
    func document_view(_ info: STCPackageInfo, images: [UIImage], changer_modules: [ChangerModule], tool_modules: [ToolModule], scenes: [SCNScene], kinematic_groups: [KinematicGroup])
    {
        self.package_info = info
        
        self.images = images
        self.scenes = scenes
        self.kinematic_groups = kinematic_groups
        
        self.changer_modules = changer_modules
        self.tool_modules = tool_modules
    }
    
    func document_view(_ document: STCDocument, _ bookmark_url: URL? = nil)
    {
        self.package_info = document.package_info
        
        self.images = document.images
        self.listings = document.listings
        self.listings_files_names = document.listings_files_names
        self.kinematic_groups = document.kinematic_groups
        
        self.robot_modules = document.robot_modules
        self.tool_modules = document.tool_modules
        self.part_modules = document.part_modules
        self.changer_modules = document.changer_modules
        
        //Deferred import for scenes
        if let folder_bookmark = get_bookmark(url: bookmark_url) //self.scenes = document.scenes
        {
            let scene_file_data = document.deferred_scene_view(folder_bookmark: folder_bookmark)
            self.scenes = scene_file_data.scenes
            self.scenes_files_names = scene_file_data.names
        }
    }
    
    private func get_bookmark(url: URL?) -> Data?
    {
        guard ((url?.startAccessingSecurityScopedResource()) != nil) else
        {
            return nil
        }
        
        defer { url?.stopAccessingSecurityScopedResource() }
        
        do
        {
            let bookmark = try url?.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmark
        }
        catch
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    //MARK: - Components handling
    //Imported files
    @Published var images = [UIImage]()
    @Published var listings = [String]()
    @Published var scenes = [SCNScene]()
    @Published var kinematic_groups = [KinematicGroup]()
    
    //Imported files names
    public var scenes_files_names = [String]()
    public var images_files_names = [String]()
    public var listings_files_names = [String]()
    
    //MARK: Kinematic groups functions
    //Build virtual robot components by kinematic group
    public func make_copmponents_from_kinematic(group: KinematicGroup, node: SCNNode, make_controller: Bool, make_model: Bool, listings_update_function: (() -> Void) = {}, scenes_update_function: (() -> Void) = {})
    {
        if make_controller
        {
            listings.append(generate_controller_code(group: group))
            
            //listings_files_names.append("\(group.name)_Controller")
            listings_files_names.append(mismatched_name(name: "\(group.name)_Controller", names: listings_files_names))
            
            listings_update_function()
        }
        
        if make_model
        {
            let scene = SCNScene()
            scene.rootNode.addChildNode(node.clone())
            
            scenes.append(scene)
            
            //scenes_files_names.append("\(group.name).scn")
            scenes_files_names.append(mismatched_name(name: "\(group.name).scn", names: scenes_files_names))
            
            scenes_update_function()
        }
    }
    
    public func generate_controller_code(group: KinematicGroup) -> String
    {
        var controller_code = listing_template(type: group.type)
        
        //controller_code = controller_code.replacingOccurrences(of: "<#name#>", with: group.name)
        controller_code = controller_code.replacingOccurrences(of: "<#name#>", with: group.name.prefix(1).rangeOfCharacter(from: .decimalDigits) != nil ? "_\(group.name)" : group.name)

        
        controller_code = controller_code.replacingOccurrences(of: "<#lengths#>", with: kinematic_data_to_code(group.data))
        
        return controller_code
        
        func kinematic_data_to_code(_ kinematic_data: [KinematicElement]) -> String
        {
            var code = String()
            
            code = """
                let lengths: [Float] = [
                        \(kinematic_data.map { "\($0.value)" }.joined(separator: ",\n        "))
                    ]
                """
            
            return code
        }
        
        func listing_template(type: KinematicGroupType) -> String
        {
            var code = String()
            
            switch group.type
            {
            case .portal:
                code = import_text_data(from: "Portal_Controller")
            case ._6DOF:
                code = import_text_data(from: "6DOF_Controller")
            }
            
            return code
        }
    }
    
    //MARK: Model nodes functions
    @Published var viewed_model_node = SCNNode()
    
    private func make_preview()
    {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        box.materials = [material]
        viewed_model_node = SCNNode(geometry: box)
    }
    
    //MARK: - Modules handling
    //MARK: Robot modules
    @Published var robot_modules = [RobotModule]()
    
    public var robot_modules_names: [String]
    {
        get
        {
            var names = [String]()
            for robot_module in robot_modules
            {
                names.append(robot_module.name)
            }
            
            return names
        }
        
        set
        {
            print(newValue)
        }
    }
    
    //MARK: Tool modules
    @Published var tool_modules = [ToolModule]()
    
    public var tool_modules_names: [String]
    {
        get
        {
            var names = [String]()
            for tool_module in tool_modules
            {
                names.append(tool_module.name)
            }
            
            return names
        }
        
        set
        {
            print(newValue)
        }
    }
    
    //MARK: Part modules
    @Published var part_modules = [PartModule]()
    
    public var part_modules_names: [String]
    {
        get
        {
            var names = [String]()
            for part_module in part_modules
            {
                names.append(part_module.name)
            }
            
            return names
        }
        
        set
        {
            print(newValue)
        }
    }
    
    
    //MARK: Changer modules
    @Published var changer_modules = [ChangerModule]()
    
    public var changer_modules_names: [String]
    {
        get
        {
            var names = [String]()
            for changer_module in changer_modules
            {
                names.append(changer_module.name)
            }
            
            return names
        }
        
        set
        {
            print(newValue)
        }
    }
    
    //MARK: Build functions
    ///Builds modules in separated files.
    public func build_modules_files(list: BuildModulesList)
    {
        
    }
    
    ///Builds application project to compile with modules.
    public func build_application_project(list: BuildModulesList)
    {
        
    }
}

//MARK: - Typealiases
#if os(macOS)
typealias UIImage = NSImage

extension UIImage
{
    func pngData() -> Data?
    {
        if let tiffRepresentation = self.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
        {
            return bitmapImage.representation(using: .png, properties: [:])
        }

        return nil
    }
}
#endif
