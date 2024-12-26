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
            module.code_items["Controller"] = generate_controller_code(group: group, name: module.name.code_correct_format)
            
            module.nodes_names = group.type.nodes_names
            
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
        
        controller_code = controller_code.replacingOccurrences(of: "<#Name#>", with: class_name)
        
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
    
    //MARK: - UI Info
    @Published var on_building_modules: Bool = false
    @Published var build_progress: Float = 0
    @Published var build_total: Float = 0
    @Published var build_info: String = String()
    
    ///Progressbar startup info
    private func set_building_info(list: BuildModulesList, as_internal: Bool)
    {
        build_progress = 0
        
        build_total += Float(robot_modules.filter { list.robot_modules_names.contains($0.name) }.count)
        build_total += Float(tool_modules.filter { list.tool_modules_names.contains($0.name) }.count)
        build_total += Float(part_modules.filter { list.part_modules_names.contains($0.name) }.count)
        build_total += Float(changer_modules.filter { list.changer_modules_names.contains($0.name) }.count)
        
        build_total -= 1
        
        self.build_info = String()
        
        if as_internal
        {
            
        }
        else
        {
            
        }
    }
    
    //MARK: - Building functions
    ///Builds modules in separated files.
    public func build_external_modules(list: BuildModulesList, to folder_url: URL)
    {
        set_building_info(list: list, as_internal: false)
        on_building_modules = true
        
        guard folder_url.startAccessingSecurityScopedResource() else { return }
        
        build_modules_files(list: list, to: folder_url, as_internal: false)
        
        folder_url.stopAccessingSecurityScopedResource()
        
        build_info = "Finished"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75)
        {
            self.on_building_modules = false
        }
        //on_building_modules = false
    }
    
    ///Builds application project to compile with internal modules.
    public func build_application_project(list: BuildModulesList, to folder_url: URL)
    {
        set_building_info(list: list, as_internal: true)
        on_building_modules = true
        
        do
        {
            //Internal modules folder
            guard folder_url.startAccessingSecurityScopedResource() else { return }
            let package_folder_url = try make_folder("Modules", module_url: folder_url)
            
            build_modules_files(list: list, to: package_folder_url, as_internal: true)
            
            //Make Internal Modules List
            var list_code = import_text_data(from: "List")
            
            let placeholders = [
                ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Robot Module@*//*@END_MENU_TOKEN@*/", list.robot_modules_names),
                ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Tool Module@*//*@END_MENU_TOKEN@*/", list.tool_modules_names),
                ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Part Module@*//*@END_MENU_TOKEN@*/", list.part_modules_names),
                ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Changer Module@*//*@END_MENU_TOKEN@*/", list.changer_modules_names)
            ]
            
            for (placeholder, names) in placeholders
            {
                let formatted_names = names.map { "\($0.code_correct_format)_Module" }.joined(separator: ",\n        ")
                list_code = list_code.replacingOccurrences(of: placeholder, with: formatted_names, options: .literal, range: nil)
            }
            
            do
            {
                try list_code.write(to: package_folder_url.appendingPathComponent("List.swift"), atomically: true, encoding: .utf8)
            }
            catch
            {
                print(error.localizedDescription)
            }
            
            do { folder_url.stopAccessingSecurityScopedResource() }
            
            build_info = "Finished"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75)
            {
                self.on_building_modules = false
            }
            //on_building_modules = false
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    ///Builds modules in separated files.
    private func build_modules_files(list: BuildModulesList, to folder_url: URL, as_internal: Bool = false)
    {
        let filtered_robot_modules = robot_modules.filter { list.robot_modules_names.contains($0.name) }
        for robot_module in filtered_robot_modules
        {
            build_module_file(module: robot_module, to: folder_url, as_internal: as_internal)
            
            build_progress += 1
        }
        
        let filtered_tool_modules = tool_modules.filter { list.tool_modules_names.contains($0.name) }
        for tool_module in filtered_tool_modules
        {
            build_module_file(module: tool_module, to: folder_url, as_internal: as_internal)
            
            build_progress += 1
        }
        
        let filtered_part_modules = part_modules.filter { list.part_modules_names.contains($0.name) }
        for part_module in filtered_part_modules
        {
            build_module_file(module: part_module, to: folder_url, as_internal: as_internal)
            
            build_progress += 1
        }
        
        let filtered_changer_modules = changer_modules.filter { list.changer_modules_names.contains($0.name) }
        for changer_module in filtered_changer_modules
        {
            build_module_file(module: changer_module, to: folder_url, as_internal: as_internal)
            
            build_progress += 1
        }
    }
    
    //MARK: Build module file
    private func build_module_file(module: IndustrialModule, to folder_url: URL, as_internal: Bool = true)
    {
        do
        {
            let module_url = try make_folder("\(module.name).\(module.extension_name)", module_url: folder_url)
            
            //Info file store
            if as_internal
            {
                try make_module_code(url: module_url)
            }
            else
            {
                try make_info_file(url: module_url)
            }
            
            //Code folder store
            let code_url = try make_module_folder("Code", module_url: module_url, module_name: module.name, as_internal: as_internal)
            
            if as_internal
            {
                if module is RobotModule || module is ToolModule || module is ChangerModule //Inject parameters in code items
                {
                    var updated_code_items = module.code_items
                    
                    if module is RobotModule || module is ToolModule
                    {
                        inject_controller_parameters(code: &updated_code_items["Controller"], module: module)
                        
                        inject_connector_parameters(code: &updated_code_items["Connector"], module: module)
                    }
                    
                    updated_code_items = updated_code_items.reduce(into: [String: String]())
                    { result, entry in
                        result["\(module.name)_\(entry.key)"] = entry.value
                    }
                    
                    try code_files_store(code_items: updated_code_items, to: code_url)
                }
            }
            else
            {
                try code_files_store(code_items: module.code_items, to: code_url) //Store external files without parameters inject
            }
            
            guard !(module is ChangerModule) else { return } //Changer module has no visual resources...
            
            //Resources folder store
            let resources_url = try make_module_folder("Resources.scnassets", module_url: module_url, module_name: module.name, as_internal: as_internal)
            
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
        
        func make_module_code(url: URL) throws //For internal module
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
        
        func make_info_file(url: URL) throws //For external module
        {
            let info_data = module.json_data()
            let info_url = url.appendingPathComponent("Info")
            try info_data.write(to: info_url)
        }
        
        func make_module_folder(_ folder_name: String, module_url: URL, module_name: String, as_internal: Bool) throws -> URL
        {
            let folder_url = module_url.appendingPathComponent(as_internal ? "\(module_name)_\(folder_name)" : folder_name)
            
            if FileManager.default.fileExists(atPath: folder_url.path)
            {
                try FileManager.default.removeItem(at: folder_url)
            }
            try FileManager.default.createDirectory(at: folder_url, withIntermediateDirectories: true, attributes: nil)
            
            return folder_url
        }
        
        func code_files_store(code_items: [String: String], to code_url: URL) throws //Store code items to listings
        {
            for code_item in code_items //Store external files without parameters inject
            {
                let code_item_url = code_url.appendingPathComponent("\(code_item.key).swift")
                try code_item.value.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
        }
        
        func inject_controller_parameters(code: inout String?, module: IndustrialModule) //Inject model controller parameters (nodes names) to internal code file
        {
            var nodes_names = String()
            
            if let robot_module = module as? RobotModule
            {
                nodes_names = robot_module.nodes_names.map { "\"\($0)\"" }.joined(separator: ",\n            ")
            }
            
            if let tool_odule = module as? ToolModule
            {
                nodes_names = tool_odule.nodes_names.map { "\"\($0)\"" }.joined(separator: ",\n            ")
            }
            
            code = code?.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=nodes_names@*//*@END_MENU_TOKEN@*/", with: nodes_names)
        }
        
        func inject_connector_parameters(code: inout String?, module: IndustrialModule) //Inject model connection parameters to internal code file
        {
            var connection_parameters = String()
            
            if let robot_module = module as? RobotModule
            {
                connection_parameters = robot_module.connection_parameters.map { "\($0.code_text)" }.joined(separator: ",\n            ")
            }
            
            if let tool_module = module as? ToolModule
            {
                connection_parameters = tool_module.connection_parameters.map { "\($0.code_text)" }.joined(separator: ",\n            ")
            }
            
            code = code?.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=connection_parameters@*//*@END_MENU_TOKEN@*/", with: connection_parameters)
        }
        
        func resource_data(_ name: String) -> Data? //Store visual data
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
    
    //MARK: - Module code (for internal)
    private func robot_module_code(_ module: RobotModule) -> String
    {
        var code = import_text_data(from: "Robot Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
        code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
        
        //Components
        if !(module.code_items["Controller"]?.isEmpty ?? false)
        {
            code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=RobotModelController()@*/RobotModelController()/*@END_MENU_TOKEN@*/", with: "\(module.name.code_correct_format)_Controller()")
        }
        
        if !(module.code_items["Connector"]?.isEmpty ?? false)
        {
            code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=RobotConnector()@*/RobotConnector()/*@END_MENU_TOKEN@*/", with: "\(module.name.code_correct_format)_Connector()")
        }
        
        //Main Nodes
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: module.scene_code_name)
        
        //Connected nodes names
        let nodes_names = "[" + module.nodes_names.map { "\"\($0)\"" }.joined(separator: ", ") + "]"
        code = code.replacingOccurrences(of: "<#nodes_names#>", with: nodes_names)
        
        return code
    }
    
    private func tool_module_code(_ module: ToolModule) -> String
    {
        var code = import_text_data(from: "Tool Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
        code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
        
        //Components
        if !(module.code_items["Controller"]?.isEmpty ?? false)
        {
            code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=ToolModelController()@*/ToolModelController()/*@END_MENU_TOKEN@*/", with: "\(module.name.code_correct_format)_Controller()")
        }
        
        if !(module.code_items["Connector"]?.isEmpty ?? false)
        {
            code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=ToolConnector()@*/ToolConnector()/*@END_MENU_TOKEN@*/", with: "\(module.name.code_correct_format)_Connector()")
        }
        
        //Main scene
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: module.scene_code_name)
        
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
        code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
        code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
        
        //Main scene
        code = code.replacingOccurrences(of: "<#main_scene_name#>", with: module.scene_code_name)
        
        return code
    }
    
    private func changer_module_code(_ module: ChangerModule) -> String
    {
        var code = import_text_data(from: "Changer Module")
        
        //Naming
        code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
        code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
        
        return code
    }
    
    private func make_folder(_ folder_name: String, module_url: URL) throws -> URL
    {
        let folder_url = module_url.appendingPathComponent(folder_name)
        
        if FileManager.default.fileExists(atPath: folder_url.path)
        {
            try FileManager.default.removeItem(at: folder_url)
        }
        try FileManager.default.createDirectory(at: folder_url, withIntermediateDirectories: true, attributes: nil)
        
        return folder_url
    }
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

extension ConnectionParameter
{
    public var code_text: String
    {
        let valueString: String
        switch value
        {
        case let stringValue as String:
            valueString = "\"\(stringValue)\""
        case let boolValue as Bool:
            valueString = "\(boolValue)"
        case let numberValue as NSNumber:
            valueString = "\(numberValue)"
        default:
            valueString = "nil"
        }
        return ".init(name: \"\(name)\", value: \(valueString))"
    }
}
