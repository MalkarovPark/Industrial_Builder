//
//  Industrial_BuilderDocument.swift
//  Industrial Builder
//
//  Created by Artem on 07.10.2023.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import IndustrialKit
import SceneKit

extension UTType
{
    static let stc_document = UTType(exportedAs: "celadon.stc")
}

struct STCDocument: FileDocument
{
    var package_info = STCPackageInfo()
    var scenes = [SCNScene]()
    var images = [UIImage]()
    var listings = [String]()
    var kinematic_groups = [KinematicGroup]()
    
    var robot_modules = [RobotModule]()
    var tool_modules = [ToolModule]()
    var part_modules = [PartModule]()
    var changer_modules = [ChangerModule]()
    
    static var readableContentTypes = [UTType.stc_document]
    
    init()
    {
        self.package_info = STCPackageInfo()
        
        self.package_info.build_modules_lists = [BuildModulesList(name: "internal_modules"), BuildModulesList(name: "external_modules")]
    }
    
    // MARK: - Import functions
    init(configuration: ReadConfiguration) throws
    {
        let wrappers = configuration.file.fileWrappers?.values
        for wrapper in wrappers!
        {
            file_process(wrapper: wrapper)
        }
        
        func file_process(wrapper: FileWrapper) // Top level files & folders
        {
            switch wrapper.filename
            {
            case "PkgInfo":
                package_process(wrapper)
            case "Modules":
                app_process(wrapper)
            case "Components":
                components_process(wrapper)
            default:
                break
            }
            
            // MARK: Package header process
            func package_process(_ wrapper: FileWrapper)
            {
                guard let data = wrapper.regularFileContents
                else
                {
                    return
                }
                
                package_info = try! JSONDecoder().decode(STCPackageInfo.self, from: data)
            }
            
            func json_decode<T: Decodable>(_ wrapper: FileWrapper, type: T.Type) -> T?
            {
                var data: T? = nil
                
                guard let file_data = wrapper.regularFileContents else
                {
                    return data
                }

                do
                {
                    data = try JSONDecoder().decode(T.self, from: file_data)
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
                return data
            }
            
            // MARK: App modules process
            func app_process(_ wrapper: FileWrapper)
            {
                if let file_wrappers = wrapper.fileWrappers
                {
                    for (_, file_wrapper) in file_wrappers
                    {
                        switch file_wrapper.filename
                        {
                        case "Robot":
                            modules_process(file_wrapper, type: RobotModule.self)
                        case "Tool":
                            modules_process(file_wrapper, type: ToolModule.self)
                        case "Part":
                            modules_process(file_wrapper, type: PartModule.self)
                        case "Changer":
                            modules_process(file_wrapper, type: ChangerModule.self)
                        default:
                            break
                        }
                    }
                }
                
                func modules_process<T>(_ wrapper: FileWrapper, type: T.Type) where T: Decodable
                {
                    if let fileWrappers = wrapper.fileWrappers
                    {
                        for (_, fileWrapper) in fileWrappers
                        {
                            if fileWrapper.filename != nil
                            {
                                switch type
                                {
                                    case is RobotModule.Type:
                                        robot_modules.append(json_decode(fileWrapper, type: RobotModule.self) ?? RobotModule())
                                    case is ToolModule.Type:
                                        tool_modules.append(json_decode(fileWrapper, type: ToolModule.self) ?? ToolModule())
                                    case is PartModule.Type:
                                        part_modules.append(json_decode(fileWrapper, type: PartModule.self) ?? PartModule())
                                    case is ChangerModule.Type:
                                        changer_modules.append(json_decode(fileWrapper, type: ChangerModule.self) ?? ChangerModule())
                                    default:
                                        break
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: Components process
            func components_process(_ wrapper: FileWrapper)
            {
                if let file_wrappers = wrapper.fileWrappers
                {
                    for (_, file_wrapper) in file_wrappers
                    {
                        switch file_wrapper.filename
                        {
                        case "KinematicGroups":
                            kinematics_process(file_wrapper)
                        case "Resources":
                            resources_process(file_wrapper)
                        case "Code":
                            codes_process(file_wrapper)
                        default:
                            break
                        }
                    }
                }
                
                func kinematics_process(_ wrapper: FileWrapper)
                {
                    if let file_wrappers = wrapper.fileWrappers
                    {
                        for (_, file_wrapper) in file_wrappers
                        {
                            if let filename = file_wrapper.filename, filename.hasSuffix(".json")
                            {
                                kinematic_groups.append(json_decode(file_wrapper, type: KinematicGroup.self) ?? KinematicGroup())
                            }
                        }
                    }
                }
                
                func resources_process(_ wrapper: FileWrapper)
                {
                    if let file_wrappers = wrapper.fileWrappers
                    {
                        for (_, file_wrapper) in file_wrappers
                        {
                            if let filename = file_wrapper.filename, filename.hasSuffix(".scn")
                            {
                                // scenes_process(file_wrapper)
                                scene_wrapper = wrapper
                                scene_folder_adress = "Components/Resources/"
                            }
                            
                            if let filename = file_wrapper.filename
                            {
                                let image_extensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp"]
                                if image_extensions.contains(where: filename.lowercased().hasSuffix)
                                {
                                    // images_process(file_wrapper)
                                    images.append(UIImage(data: file_wrapper.regularFileContents ?? Data()) ?? UIImage())
                                    
                                    images_files_names.append(URL(fileURLWithPath: filename).lastPathComponent)
                                }
                            }
                        }
                    }
                }
                
                func codes_process(_ wrapper: FileWrapper)
                {
                    if let file_wrappers = wrapper.fileWrappers
                    {
                        for (_, file_wrapper) in file_wrappers
                        {
                            if let filename = file_wrapper.filename, filename.hasSuffix(".swift"), let listing = String(data: file_wrapper.regularFileContents ?? Data(), encoding: .utf8)
                            {
                                listings.append(listing)
                                listings_files_names.append(String(filename.split(separator: ".").first!))
                            }
                        }
                    }
                }
            }
        }
    }
    
    var scene_folder_adress = String()
    var scene_wrapper: FileWrapper?
    
    var scenes_files_names = [String]()
    var images_files_names = [String]()
    var listings_files_names = [String]()
    
    public func deferred_scene_view(folder_bookmark: Data) -> (scenes: [SCNScene], names: [String])
    {
        var scenes = [SCNScene]()
        var names = [String]()
        
        guard let file_wrappers = scene_wrapper?.fileWrappers
        else
        {
            return (scenes, names)
        }
        
        for (_, file_wrapper) in file_wrappers
        {
            #if os(macOS)
            if let filename = file_wrapper.filename, filename.hasSuffix(".scn")
            {
                if let scene_data = file_wrapper.regularFileContents
                {
                    let scene_source = SCNSceneSource(data: scene_data, options: nil)
                    if let scene = scene_source?.scene(options: nil)
                    {
                        scenes.append(scene_view(scene_address: "\(scene_folder_adress)\(filename)", folder_bookmark: folder_bookmark))
                        
                        let filename_no_ext = URL(fileURLWithPath: filename).lastPathComponent
                        names.append(filename_no_ext)
                    }
                    else
                    {
                        print("Error load from \(filename)")
                    }
                }
            }
            #else
            if let filename = file_wrapper.filename
            {
                if let scene_data = file_wrapper.regularFileContents
                {
                    let scene_source = SCNSceneSource(data: scene_data, options: nil)
                    if let scene = scene_source?.scene(options: nil)
                    {
                        scenes.append(scene_view(scene_address: "\(scene_folder_adress)\(filename)", folder_bookmark: folder_bookmark))
                        
                        let filename_no_ext = URL(fileURLWithPath: filename).lastPathComponent
                        names.append(filename_no_ext)
                    }
                    else
                    {
                        print("Error load from \(filename)")
                    }
                }
            }
            #endif
        }
        
        return (scenes, names)
    }
    
    private func scene_view(scene_address: String, folder_bookmark: Data) -> SCNScene
    {
        let scene = SCNScene()
        do
        {
            // File access
            var is_stale = false
            let url = try URL(resolvingBookmarkData: folder_bookmark, bookmarkDataIsStale: &is_stale)
            
            guard !is_stale else
            {
                return scene
            }
            
            do
            {
                print(url.absoluteString + "/" + scene_address)
                let scene = try SCNScene(url: url.appendingPathComponent(scene_address))
                return scene
            }
        }
        catch
        {
            print(error.localizedDescription)
            return scene
        }
    }
    
    // MARK: - Export functions
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        do
        {
            // Store package info data
            let data = try build_document_data()
            let json_file_wrapper = FileWrapper(regularFileWithContents: data)
            let package_filename = "PkgInfo"
            json_file_wrapper.filename = package_filename
            
            // Store modules data
            var app_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            app_file_wrapper = try build_modules_file_wrapper()
            
            // Store components data
            var components_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            components_file_wrapper = try build_components_file_wrapper()
            
            let file_wrapper = FileWrapper(directoryWithFileWrappers: [
                package_filename: json_file_wrapper,
                "Modules": app_file_wrapper,
                "Components": components_file_wrapper
            ])
            
            return file_wrapper
        }
        catch
        {
            throw error
        }
    }
    
    // MARK: Document header store
    private func build_document_data() throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(package_info)
            return data
        }
        catch
        {
            throw error
        }
    }
    
    // MARK: App modules store
    func build_modules_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        // Robot Modules
        file_wrappers["Robot"] = prepare_robot_modules_wrapper()
        
        // Tool Modules
        file_wrappers["Tool"] = prepare_tool_modules_wrapper()
        
        // Part Modules
        file_wrappers["Part"] = prepare_part_modules_wrapper()
        
        // Changer Modules
        file_wrappers["Changer"] = prepare_changer_modules_wrapper()
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
        
        func prepare_robot_modules_wrapper() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for robot_module in robot_modules
            {
                guard let data = try? make_json_data(robot_module) else
                {
                    break
                }
                
                let file_name = "\(robot_module.name)"//.json"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        func prepare_tool_modules_wrapper() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for tool_module in tool_modules
            {
                guard let data = try? make_json_data(tool_module) else
                {
                    break
                }
                
                let file_name = "\(tool_module.name)"//.json"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        func prepare_part_modules_wrapper() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for part_module in part_modules
            {
                guard let data = try? make_json_data(part_module) else
                {
                    break
                }
                
                let file_name = "\(part_module.name)"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        func prepare_changer_modules_wrapper() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for changer_module in changer_modules
            {
                guard let data = try? make_json_data(changer_module) else
                {
                    break
                }
                
                let file_name = "\(changer_module.name)" // .json"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
    }
    
    // MARK: Components store
    // New files names
    static var new_scenes_names = [String]()
    static var new_images_names = [String]()
    
    func build_components_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        // Resources
        file_wrappers["Resources"] = prepare_resources_wrappers()
        
        func prepare_resources_wrappers() -> FileWrapper
        {
            // Scenes
            var file_wrappers = [String: FileWrapper]()
            
            var index = 0
            for scene in scenes
            {
                let scene_data = try? NSKeyedArchiver.archivedData(withRootObject: scene, requiringSecureCoding: true)
                guard let data = scene_data else { continue }
                
                let file_name = STCDocument.new_scenes_names[index]
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
                
                index += 1
            }
            
            // Images
            index = 0
            for image in images
            {
                guard let data = image.pngData() else
                {
                    break
                }
                
                let file_name = STCDocument.new_images_names[safe: index] ?? "Image \(index).png"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
                index += 1
            }
            
            print(file_wrappers)
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        // Listings
        file_wrappers["Code"] = prepare_listings_wrappers()
        
        func prepare_listings_wrappers() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for (index, listing) in listings.enumerated()
            {
                let file_name = "\(listings_files_names[index]).swift"
                
                guard let data = listing.data(using: .utf8) else
                {
                    break
                }
                
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        // Kinematic groups
        file_wrappers["KinematicGroups"] = prepare_kinematics_wrappers()
        
        func prepare_kinematics_wrappers() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for kinematic_group in kinematic_groups
            {
                guard let data = try? make_json_data(kinematic_group) else
                {
                    break
                }
                
                let file_name = "\(kinematic_group.name).json"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    private func make_json_data(_ object: Encodable) throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(object)
            return data
        }
        catch
        {
            throw error
        }
    }
}
