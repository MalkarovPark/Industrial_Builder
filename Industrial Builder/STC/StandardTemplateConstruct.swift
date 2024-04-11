//
//  StandardTemplateConstruct.swift
//  Industrial Builder
//
//  Created by Artem on 16.10.2023.
//

import Foundation
import SwiftUI
import SceneKit

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package_info = STCPackageInfo()
    @Published var images = [UIImage]()
    @Published var listings = [String]()
    
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
    
    func document_view(_ document: STCDocument)
    {
        self.package_info = document.package_info
        self.images = document.images
        self.listings = document.listings
        self.listings_files_names = document.listings_files_names
        
        //self.scenes = document.scenes
        self.kinematic_groups = document.kinematic_groups
        
        self.changer_modules = document.changer_modules
        self.tool_modules = document.tool_modules
    }
    
    //Imported files names
    public var scenes_files_names = [String]()
    public var images_files_names = [String]()
    public var listings_files_names = [String]()
    
    //MARK: - Components handling
    //MARK: Kinematic groups functions
    @Published var kinematic_groups = [KinematicGroup]()
    
    //MARK: Model nodes functions
    @Published var scenes = [SCNScene]()
    @Published var viewed_model_node = SCNNode()
    
    private func make_preview()
    {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        box.materials = [material]
        viewed_model_node = SCNNode(geometry: box)
    }
    
    /*private func make_contents()
    {
        for i in 0..<17
        {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
            box.materials = [material]
            
            scenes.append(SCNNode(geometry: box))
        }
    }*/
    
    //MARK: - Modules handling
    //MARK: Changer modules functions
    @Published var changer_modules = [ChangerModule]()
    
    //MARK: Robot modules
    
    //MARK: Tool modules
    @Published var tool_modules = [ToolModule]()
    
    #if os(macOS)
    @Published var selected_tool_module_name = ""
    #else
    @Published var selected_tool_module_name: String? = ""
    #endif
    
    public var tool_modules_names: [String]
    {
        var names = [String]()
        for tool_module in tool_modules
        {
            names.append(tool_module.name)
        }
        
        return names
    }
    
    public var selected_tool_module: ToolModule
    {
        get
        {
            return tool_modules.first { $0.name == selected_tool_module_name } ?? ToolModule()
        }
        set
        {
            if let index = tool_modules.firstIndex(where: { $0.name == selected_tool_module_name })
            {
                tool_modules[index] = newValue
            }
        }
    }
    
    public func remove_selected_tool_module()
    {
        tool_modules.removeAll { $0.name == selected_tool_module_name }
    }
    
    public func deselect_tool_module()
    {
        selected_tool_module_name = ""
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
