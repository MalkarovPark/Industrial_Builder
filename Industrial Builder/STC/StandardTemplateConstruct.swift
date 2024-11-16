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
            if let existing_index = listings_files_names.firstIndex(of: group.name)
            {
                listings[existing_index] = generate_controller_code(group: group)
                listings_files_names[existing_index] = group.name
            }
            else
            {
                listings.append(generate_controller_code(group: group))
                listings_files_names.append(group.name)
            }
            
            listings_update_function()
        }
        
        if make_model
        {
            let scene = SCNScene()
            scene.rootNode.addChildNode(node.clone())
            
            if let existing_index = scenes_files_names.firstIndex(of: "\(group.name).scn")
            {
                scenes[existing_index] = scene
                scenes_files_names[existing_index] = "\(group.name).scn"
            }
            else
            {
                scenes.append(scene)
                scenes_files_names.append(group.name)
            }
            
            scenes_update_function()
        }
    }
    
    //Build virtual robot components by kinematic group to robot model
    public func make_copmponents_from_kinematic(group: KinematicGroup, to module_name: String, node: SCNNode, make_controller: Bool, make_model: Bool, robots_update_function: (() -> Void) = {}, scenes_update_function: (() -> Void) = {})
    {
        guard let module = robot_modules.first(where: { $0.name == module_name })
        else
        {
            return
        }
        
        if make_controller
        {
            module.code_items["Controller"] = generate_controller_code(group: group, name: module.name)
            
            robots_update_function()
        }
        
        if make_model
        {
            //Make scene
            let scene = SCNScene()
            scene.rootNode.addChildNode(node.clone())
            
            //Pass scene to resources
            let new_scene_name = "\(group.name).scn"
            
            if let existing_index = scenes_files_names.firstIndex(of: new_scene_name)
            {
                scenes[existing_index] = scene
                scenes_files_names[existing_index] = new_scene_name
            }
            else
            {
                scenes.append(scene)
                scenes_files_names.append(new_scene_name)
            }
            
            //Connect scene to module
            if module.resources_names == nil
            {
                module.resources_names = [new_scene_name]
            }
            else
            {
                if module.resources_names?.firstIndex(of: new_scene_name) == nil
                {
                    module.resources_names?.append(new_scene_name)
                }
            }
            
            module.main_scene_name = new_scene_name
            
            //Set nodes names connect in scene
            //module.nodes_names = group.type.nodes_list
            
            scenes_update_function()
        }
    }
    
    private func generate_controller_code(group: KinematicGroup, name: String = String()) -> String
    {
        var controller_code = group.type.listing_template
        
        var class_name = String()
        
        if !name.isEmpty
        {
            class_name = name
        }
        else
        {
            class_name = group.name
        }
        
        //controller_code = controller_code.replacingOccurrences(of: "<#Name#>", with: class_name)
        controller_code = controller_code.replacingOccurrences(of: "<#Name#>", with: code_correct_name(class_name))
        
        controller_code = controller_code.replacingOccurrences(of: "<#lengths#>", with: kinematic_data_to_code(group.data))
        
        return controller_code
    }
    
    private func kinematic_data_to_code(_ kinematic_data: [KinematicElement]) -> String
    {
        var code = String()
        
        code = """
        \(kinematic_data.map { "\($0.value)" }.joined(separator: ",\n        "))
        """
        
        return code
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
    public func build_modules_files(list: BuildModulesList, to folder_url: URL, as_internal: Bool = false)
    {
        guard (folder_url.startAccessingSecurityScopedResource()) else
        {
            return
        }
        
        for robot_module in robot_modules
        {
            build_module_file(module: robot_module, to: folder_url, as_internal: as_internal)
        }
        
        for tool_module in tool_modules
        {
            build_module_file(module: tool_module, to: folder_url, as_internal: as_internal)
        }
        
        for part_module in part_modules
        {
            build_module_file(module: part_module, to: folder_url, as_internal: as_internal)
        }
        
        for changer_module in changer_modules
        {
            build_module_file(module: changer_module, to: folder_url, as_internal: as_internal)
        }
        
        do { folder_url.stopAccessingSecurityScopedResource() }
    }
    
    ///Builds application project to compile with modules.
    public func build_application_project(list: BuildModulesList, to folder_url: URL)
    {
        build_modules_files(list: list, to: folder_url, as_internal: true)
        
        //Make List
        guard (folder_url.startAccessingSecurityScopedResource()) else
        {
            return
        }
        
        var list_code = import_text_data(from: "List")
        
        let placeholders = [
            ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Robot Module@*//*@END_MENU_TOKEN@*/", robot_modules_names),
            ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Tool Module@*//*@END_MENU_TOKEN@*/", tool_modules_names),
            ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Part Module@*//*@END_MENU_TOKEN@*/", part_modules_names),
            ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Changer Module@*//*@END_MENU_TOKEN@*/", changer_modules_names)
        ]
        
        for (placeholder, names) in placeholders
        {
            for module_name in names
            {
                list_code = list_code.replacingOccurrences(of: placeholder, with: module_name, options: .literal, range: nil)
            }
        }
        
        do
        {
            try list_code.write(to: folder_url.appendingPathComponent("List.swift"), atomically: true, encoding: .utf8)
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        do { folder_url.stopAccessingSecurityScopedResource() }
    }
    
    private func build_module_file(module: IndustrialModule, to folder_url: URL, as_internal: Bool = true)
    {
        do
        {
            let module_url = folder_url.appendingPathComponent("\(module.name).\(module.extension_name)") //type(of: module).extension_name
            try FileManager.default.createDirectory(at: module_url, withIntermediateDirectories: true, attributes: nil)
            
            //Info file store
            if as_internal
            {
                try make_module_code(url: module_url)
            }
            else
            {
                try make_info(url: module_url)
            }
            
            //Code folder store
            let code_url = try make_folder("Code", module_url: module_url, module_name: module.name, as_internal: as_internal)
            
            for code_item in module.code_items
            {
                let code_item_url = code_url.appendingPathComponent("\(code_item.key).swift")
                try code_item.value.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
            
            guard !(module is ChangerModule) else { return }
            
            //Resources folder store
            let resources_url = try make_folder("Resources.scnassets", module_url: module_url, module_name: module.name, as_internal: as_internal)
            
            if let resources_names = module.resources_names
            {
                for resource_name in resources_names
                {
                    let resource_url = resources_url.appendingPathComponent(resource_name)
                    try resource_data(resource_name)?.write(to: resource_url)
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
        
        func make_module_code(url: URL) throws
        {
            let code_item_url = url.appendingPathComponent("\(module.name)_Module.swift")
            
            var module_code = String()

            switch module
            {
            case is RobotModule:
                module_code = robot_module_code(module as? RobotModule ?? RobotModule())
            case is ToolModule:
                module_code = tool_module_code(module as? ToolModule ?? ToolModule())
            case is PartModule:
                module_code = part_module_code(module as? PartModule ?? PartModule())
            case is ChangerModule:
                module_code = changer_module_code(module as? ChangerModule ?? ChangerModule())
            default:
                break
            }
            
            try module_code.write(to: code_item_url, atomically: true, encoding: .utf8)
        }
        
        func make_info(url: URL) throws
        {
            let info_data = module.json_data()
            let info_url = url.appendingPathComponent("Info")
            try info_data.write(to: info_url)
        }
        
        func make_folder(_ folder_name: String, module_url: URL, module_name: String, as_internal: Bool = true) throws -> URL
        {
            let folder_url = module_url.appendingPathComponent(as_internal ? "\(module_name)_\(folder_name)" : folder_name)
            
            if FileManager.default.fileExists(atPath: folder_url.path)
            {
                try FileManager.default.removeItem(at: folder_url)
            }
            try FileManager.default.createDirectory(at: folder_url, withIntermediateDirectories: true, attributes: nil)
            
            return folder_url
        }
        
        func resource_data(_ name: String) -> Data?
        {
            var data: Data? = nil

            let file_extension = (name as NSString).pathExtension.lowercased()
            //let file_name = (name as NSString).deletingPathExtension
            
            if file_extension == "scn"
            {
                if let scene_index = scenes_files_names.firstIndex(of: name)
                {
                    data = try? NSKeyedArchiver.archivedData(withRootObject: scenes[scene_index], requiringSecureCoding: false)
                }
            }
            else if ["png", "jpg", "jpeg", "gif", "bmp"].contains(file_extension)
            {
                print(images_files_names)
                if let image_index = images_files_names.firstIndex(of: name)
                {
                    guard let image_data = images[image_index].pngData() else
                    {
                        return nil
                    }
                    data = image_data
                }
            }
            else
            {
                print("Uncompatible file format: \(file_extension)")
            }

            return data
        }
    }
    
    private func robot_module_code(_ module: RobotModule) -> String
    {
        var code = import_text_data(from: "Robot Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: code_correct_name(module.name))
        
        //Main Nodes
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: code_correct_name(module.main_scene_name ?? "\(module.name).scn"))
        
        //Connected nodes names
        let nodes_names = "[" + module.nodes_names.map { "\"\($0)\"" }.joined(separator: ", ") + "]"
        code = code.replacingOccurrences(of: "<#nodes_names#>", with: nodes_names)
        
        return code
    }
    
    private func tool_module_code(_ module: ToolModule) -> String
    {
        var code = import_text_data(from: "Tool Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: code_correct_name(module.name))
        
        //Main Nodes
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: code_correct_name(module.main_scene_name ?? "\(module.name).scn"))
        
        //Connected nodes names
        //let nodes_names = "[" + module.nodes_names.map { "\"\($0)\"" }.joined(separator: ", ") + "]"
        //code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=nodes_names@*//*@END_MENU_TOKEN@*/", with: nodes_names)
        
        //Operation codes
        code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=operation_codes@*//*@END_MENU_TOKEN@*/", with: opcode_data_to_code(module.codes))
        
        return code
        
        func opcode_data_to_code(_ data: [OperationCodeInfo]) -> String
        {
            return """
            \(data.map
            {
                ".init(value: \($0.value), name: \"\($0.name)\", symbol: \"\($0.symbol)\", info: \"\($0.info)\")"
            }
            .joined(separator: ",\n        "))
            """
        }
    }
    
    private func part_module_code(_ module: PartModule) -> String
    {
        var code = import_text_data(from: "Part Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: code_correct_name(module.name))
        
        //Main Nodes
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: code_correct_name(module.main_scene_name ?? "\(module.name).scn"))
        
        return code
    }
    
    private func changer_module_code(_ module: ChangerModule) -> String
    {
        var code = import_text_data(from: "Changer Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: code_correct_name(module.name))
        
        return code
    }
}

public func code_correct_name(_ name: String) -> String
{
    let new_name = name.replacingOccurrences(of: " ", with: "_")
    return new_name.prefix(1).rangeOfCharacter(from: .decimalDigits) != nil ? "_\(name)" : name
}

public func safe_spaces_name(_ name: String) -> String
{
    return name.replacingOccurrences(of: " ", with: "_") //For SCNScene import...
}

//MARK: - Typealiases
#if os(macOS)
typealias UIImage = NSImage

//MARK: - Extensions
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
