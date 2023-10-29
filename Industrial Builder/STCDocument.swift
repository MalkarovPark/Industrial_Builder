//
//  Industrial_BuilderDocument.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 07.10.2023.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import IndustrialKit

extension UTType
{
    static let stc_document = UTType(exportedAs: "celadon.IndustrialBuilder.stc")
}

struct STCDocument: FileDocument
{
    var package = STCPackage()
    var images = [UIImage]()
    
    var changer_modules = [ChangerModule]()
    var tool_modules = [ToolModule]()
    
    var kinematic_groups = [KinematicGroup]()
    
    static var readableContentTypes = [UTType.stc_document]
    
    init()
    {
        self.package = STCPackage()
    }
    
    //MARK: - Import functions
    init(configuration: ReadConfiguration) throws
    {
        let wrappers = configuration.file.fileWrappers?.values
        for wrapper in wrappers!
        {
            file_process(wrapper: wrapper)
        }
        
        func file_process(wrapper: FileWrapper)
        {
            switch wrapper.filename
            {
            case "Package.info":
                package_process(wrapper)
            case "Images":
                images_process(wrapper)
            case "App":
                app_process(wrapper)
            case "Components":
                components_process(wrapper)
            default:
                break
            }
            
            func package_process(_ wrapper: FileWrapper)
            {
                guard let data = wrapper.regularFileContents
                else
                {
                    return
                }
                
                package = try! JSONDecoder().decode(STCPackage.self, from: data)
            }
            
            func images_process(_ wrapper: FileWrapper)
            {
                if let file_wrappers = wrapper.fileWrappers
                {
                    for (_, file_wrapper) in file_wrappers
                    {
                        if let filename = file_wrapper.filename, filename.hasSuffix(".png")
                        {
                            images.append(UIImage(data: file_wrapper.regularFileContents ?? Data()) ?? UIImage())
                        }
                    }
                }
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
                    print("Error decoding JSON: \(error)")
                }
                
                return data
            }
            
            func app_process(_ wrapper: FileWrapper)
            {
                if let file_wrappers = wrapper.fileWrappers
                {
                    for (_, file_wrapper) in file_wrappers
                    {
                        switch file_wrapper.filename
                        {
                        case "ChangerModules.json":
                            changer_modules_process(file_wrapper)
                        case "RobotModules":
                            robot_modules_process(file_wrapper)
                        case "ToolModules":
                            tool_modules_process(file_wrapper)
                        default:
                            break
                        }
                    }
                }
                
                func changer_modules_process(_ wrapper: FileWrapper)
                {
                    changer_modules = json_decode(wrapper, type: [ChangerModule].self)!
                }
                
                func robot_modules_process(_ wrapper: FileWrapper)
                {
                    
                }
                
                func tool_modules_process(_ wrapper: FileWrapper)
                {
                    if let file_wrappers = wrapper.fileWrappers
                    {
                        for (_, file_wrapper) in file_wrappers
                        {
                            if let filename = file_wrapper.filename, filename.hasSuffix(".json")
                            {
                                tool_modules.append(json_decode(file_wrapper, type: ToolModule.self) ?? ToolModule())
                            }
                        }
                    }
                }
            }
            
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
            }
        }
    }
    
    //MARK: - Export functions
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        do
        {
            //Store package data
            let data = try make_document_data()
            let json_file_wrapper = FileWrapper(regularFileWithContents: data)
            let package_filename = "Package.info"
            json_file_wrapper.filename = package_filename
            
            //Store images to this images_file_wrapper
            var images_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            images_file_wrapper = try prepare_image_file_wrapper(from: images)
            
            //Store modules data
            var app_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            app_file_wrapper = try prepare_app_file_wrapper()
            
            //Store components data
            var components_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            components_file_wrapper = try prepare_components_file_wrapper()
            
            let file_wrapper = FileWrapper(directoryWithFileWrappers: [
                package_filename: json_file_wrapper,
                "Images": images_file_wrapper,
                "App": app_file_wrapper,
                "Components": components_file_wrapper
            ])
            
            return file_wrapper
        }
        catch
        {
            throw error
        }
    }
    
    private func make_document_data() throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(package)
            return data
        }
        catch
        {
            throw error
        }
    }
    
    func prepare_image_file_wrapper(from images: [UIImage]) throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        var index = 0
        for image in images
        {
            guard let data = image.pngData() else
            {
                break
            }
            
            let file_name = "GalleryImage\(index + 1).png"
            let file_wrapper = FileWrapper(regularFileWithContents: data)
            file_wrapper.filename = file_name
            file_wrapper.preferredFilename = file_name
            
            file_wrappers[file_name] = file_wrapper
            index += 1
        }
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    func prepare_app_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        //Changer Modules
        file_wrappers["ChangerModules.json"] = FileWrapper(regularFileWithContents: try make_json_data(changer_modules))
        
        //Tool Modules
        file_wrappers["ToolModules"] = prepare_tool_modules_wrappers()
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
        
        func prepare_tool_modules_wrappers() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for tool_module in tool_modules
            {
                guard let data = try? make_json_data(tool_module) else
                {
                    break
                }
                
                let file_name = "\(tool_module.name).json"
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
    }
    
    func prepare_components_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        //Tool Modules
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
