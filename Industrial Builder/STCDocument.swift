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

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package = STCPackage()
    @Published var images = [UIImage]()
    
    @Published var changer_modules = [ChangerModule]()
    
    @Published var tool_modules = [ToolModule]()
    
    public var tool_modules_names: [String]
    {
        var names = [String]()
        for tool_module in tool_modules
        {
            names.append(tool_module.name)
        }
        
        return names
    }
    
    public func remove_tool_module(_ name: String)
    {
        tool_modules.removeAll { $0.name == name }
    }
    
    init()
    {
        
    }
    
    func document_view(_ info: STCPackage, images: [UIImage], changer_modules: [ChangerModule])
    {
        self.package = info
        self.images = images
        self.changer_modules = changer_modules
    }
}

public struct ChangerModule: Equatable, Codable
{
    var name = ""
    var code = ""
}

public struct ToolModule: Equatable, Codable, Hashable
{
    var id: UUID
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
    
    var name = ""
    
    var controller = ToolControllerModule()    
    var connector = ToolConnectorModule()
}

public struct ToolControllerModule: Equatable, Codable
{
    var connect = ""
    var reset = ""
    var other = ""
    
    var statistics = StatisticsFunctionsData()
}

public struct ToolConnectorModule: Equatable, Codable
{
    var connect = ""
    var perform = ""
    var disconnect = ""
    var other = ""
    
    var statistics = StatisticsFunctionsData()
}

public struct StatisticsFunctionsData: Equatable, Codable
{
    var chart_code = ""
    var clear_chart_code = ""
    
    var state_code = ""
    var clear_state_code = ""
    
    var other_code = ""
}

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

struct STCPackage: Codable
{
    var id: UUID
    var title: String
    var description: String
    
    init(id: UUID = .init(), title: String = .init(), description: String = .init())
    {
        self.id = id
        self.title = title
        self.description = description
    }
}

struct STCDocument: FileDocument
{
    var package = STCPackage()
    var images = [UIImage]()
    var changer_modules = [ChangerModule]()
    
    static var readableContentTypes = [UTType.stc_document]
    
    init()
    {
        self.package = STCPackage()
    }
    
    //MARK: Import functions
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
            
            func json_decode(_ wrapper: FileWrapper, type: Any, data: Any)
            {
                if wrapper.filename != nil
                {
                    guard let data = wrapper.regularFileContents
                    else
                    {
                        return
                    }
                    
                    changer_modules = try! JSONDecoder().decode([ChangerModule].self, from: data)
                }
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
                        case "Modules":
                            modules_process(file_wrapper)
                        default:
                            break
                        }
                    }
                }
                
                func changer_modules_process(_ wrapper: FileWrapper)
                {
                    json_decode(wrapper, type: [ChangerModule].self, data: changer_modules)
                }
                
                func modules_process(_ wrapper: FileWrapper)
                {
                    if let file_wrappers = wrapper.fileWrappers
                    {
                        for (_, file_wrapper) in file_wrappers
                        {
                            switch file_wrapper.filename
                            {
                            case "Robot Modules":
                                robot_modules_process(file_wrapper)
                            case "Tool Modules":
                                tool_modules_process(file_wrapper)
                            default:
                                break
                            }
                        }
                    }
                }
                
                func robot_modules_process(_ wrapper: FileWrapper)
                {
                    
                }
                
                func tool_modules_process(_ wrapper: FileWrapper)
                {
                    
                }
            }
        }
    }
    
    //MARK: Export functions
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
            app_file_wrapper = try prepare_app_file_wrapper(from: changer_modules)
            
            var file_wrapper = FileWrapper(directoryWithFileWrappers: [
                package_filename: json_file_wrapper,
                "Images": images_file_wrapper,
                "App": app_file_wrapper
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
    
    func prepare_app_file_wrapper(from modules: [ChangerModule]) throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        //Changer Modules
        file_wrappers["ChangerModules.json"] = FileWrapper(regularFileWithContents: try make_changer_modules_data())
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    private func make_changer_modules_data() throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(changer_modules)
            return data
        }
        catch
        {
            throw error
        }
    }
}
