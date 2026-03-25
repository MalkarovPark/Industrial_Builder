//
//  Industrial_BuilderDocument.swift
//  Industrial Builder
//
//  Created by Artem on 07.10.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import RealityKit

import IndustrialKit

extension UTType
{
    static let stc_document = UTType(exportedAs: "celadon.stc")
}

struct STCDocument: FileDocument
{
    var package_info = STCPackageInfo()
    
    var entity_items = [EntityItem]()
    var image_items = [ImageItem]()
    var listing_items = [ListingItem]()
    
    var robot_modules = [RobotModule]()
    var tool_modules = [ToolModule]()
    var part_modules = [PartModule]()
    var changer_modules = [ChangerModule]()
    
    // MARK: Prepared scene cache
    var scenes_data = [String: Data]()
    
    static var readableContentTypes = [UTType.stc_document]
    
    init()
    {
        self.package_info = STCPackageInfo()
        
        self.package_info.build_modules_list = BuildModulesList()
    }
    
    // MARK: - Import
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
                
                do
                {
                    package_info = try JSONDecoder().decode(STCPackageInfo.self, from: data)
                }
                catch
                {
                    package_info = STCPackageInfo()
                }
                //package_info = try! JSONDecoder().decode(STCPackageInfo.self, from: data)
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
                                case _ where type == RobotModule.self:
                                    if let data = json_decode(fileWrapper, type: RobotModule.self) { robot_modules.append(data) }
                                case _ where type == ToolModule.self:
                                    if let data = json_decode(fileWrapper, type: ToolModule.self) { tool_modules.append(data) }
                                case _ where type == PartModule.self:
                                    if let data = json_decode(fileWrapper, type: PartModule.self) { part_modules.append(data) }
                                case _ where type == ChangerModule.self:
                                    if let data = json_decode(fileWrapper, type: ChangerModule.self) { changer_modules.append(data) }
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
                        case "Resources":
                            resources_process(file_wrapper)
                        case "Code":
                            codes_process(file_wrapper)
                        default:
                            break
                        }
                    }
                }
                
                func resources_process(_ wrapper: FileWrapper)
                {
                    guard let file_wrappers = wrapper.fileWrappers else { return }
                    
                    entities_wrapper = wrapper
                    scenes_files_names.removeAll()
                    
                    for (_, file_wrapper) in file_wrappers
                    {
                        guard let filename = file_wrapper.filename else { continue }
                        
                        // MARK: USDZ
                        if filename.lowercased().hasSuffix(".usdz")
                        {
                            scenes_files_names.append(URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent)
                        }
                        
                        // MARK: Images
                        let image_extensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp"]
                        
                        if image_extensions.contains(where: filename.lowercased().hasSuffix)
                        {
                            if let data = file_wrapper.regularFileContents,
                               let image = UIImage(data: data)
                            {
                                image_items.append(ImageItem(name: filename, image: image))
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
                            if let filename = file_wrapper.filename, filename.hasSuffix(".swift"),
                               let listing = String(data: file_wrapper.regularFileContents ?? Data(), encoding: .utf8)
                            {
                                listing_items.append(ListingItem(name: String(filename.split(separator: ".").first!), text: listing))
                            }
                        }
                    }
                }
            }
        }
    }
    
    var scene_folder_adress = String()
    var entities_wrapper: FileWrapper?
    
    public func deferred_scene_import(folder_bookmark: Data) async -> [EntityItem]?
    {
        var entity_items = [EntityItem]()
        
        guard let file_wrappers = entities_wrapper?.fileWrappers else
        {
            return nil
        }
        
        var is_stale = false
        guard let folder_url = try? URL(
            resolvingBookmarkData: folder_bookmark,
            bookmarkDataIsStale: &is_stale
        ),
              !is_stale
        else
        {
            return nil
        }
        
        guard folder_url.startAccessingSecurityScopedResource()
        else
        {
            return nil
        }
        
        defer
        {
            folder_url.stopAccessingSecurityScopedResource()
        }
        
        await withTaskGroup(of: EntityItem?.self)
        { group in
            
            for (_, file_wrapper) in file_wrappers
            {
                if let filename = file_wrapper.filename,
                   filename.hasSuffix(".usdz")
                {
                    //let scene_url = folder_url.appendingPathComponent(filename)
                    
                    group.addTask
                    {
                        do
                        {
                            let scene_url = folder_url
                                .appendingPathComponent("Components")
                                .appendingPathComponent("Resources")
                                .appendingPathComponent(filename)
                            
                            let entity = try await Entity(contentsOf: scene_url)
                            
                            let name = URL(fileURLWithPath: filename)
                                .deletingPathExtension()
                                .lastPathComponent
                            
                            return EntityItem(name: name, entity: entity)
                        }
                        catch
                        {
                            print("\(filename): \(error)")
                            return nil
                        }
                    }
                }
            }
            
            for await result in group
            {
                if let item = result
                {
                    entity_items.append(item)
                }
            }
        }
        
        return entity_items
    }
    
    var scenes_files_names = [String]() // For deferred import
    
    var listings_files_names = [String]()
    
    // MARK: - Export
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        let data = try build_document_data()
        let json_file_wrapper = FileWrapper(regularFileWithContents: data)
        let package_filename = "PkgInfo"
        json_file_wrapper.filename = package_filename
        
        let modules_wrapper = try build_modules_file_wrapper()
        let components_wrapper = try build_components_file_wrapper()
        
        return FileWrapper(directoryWithFileWrappers: [
            package_filename: json_file_wrapper,
            "Modules": modules_wrapper,
            "Components": components_wrapper
        ])
    }
    
    private func build_document_data() throws -> Data
    {
        return try JSONEncoder().encode(package_info)
    }
    
    func build_modules_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        file_wrappers["Robot"] = make_modules(robot_modules)
        file_wrappers["Tool"] = make_modules(tool_modules)
        file_wrappers["Part"] = make_modules(part_modules)
        file_wrappers["Changer"] = make_modules(changer_modules)
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    private func make_modules<T: Encodable>(_ modules: [T]) -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        for module in modules
        {
            if let named = module as? IndustrialModule
            {
                let file_name = named.name
                let data = try? JSONEncoder().encode(module)
                let wrapper = FileWrapper(regularFileWithContents: data ?? Data())
                wrapper.filename = file_name
                wrapper.preferredFilename = file_name
                file_wrappers[file_name] = wrapper
            }
        }
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    func build_components_file_wrapper() throws -> FileWrapper
    {
        var file_wrappers = [String: FileWrapper]()
        
        // MARK: Resources
        file_wrappers["Resources"] = prepare_resources_wrappers()
        
        func prepare_resources_wrappers() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            guard let scene_files = entities_wrapper?.fileWrappers else { return FileWrapper(directoryWithFileWrappers: [:]) }
            
            for entity_item in entity_items
            {
                let file_name_with_ext = entity_item.name.hasSuffix(".usdz") ? entity_item.name : entity_item.name + ".usdz"
                
                if let source_url = entity_item.source_url
                {
                    // New file to package
                    do
                    {
                        let data = try Data(contentsOf: source_url)
                        let wrapper = FileWrapper(regularFileWithContents: data)
                        wrapper.filename = file_name_with_ext
                        wrapper.preferredFilename = file_name_with_ext
                        file_wrappers[file_name_with_ext] = wrapper
                    }
                    catch
                    {
                        print("Failed to include new entity \(entity_item.name): \(error)")
                    }
                }
                else if let wrapper = scene_files[file_name_with_ext]
                {
                    // File from package
                    file_wrappers[file_name_with_ext] = wrapper
                }
                else
                {
                    print("Warning: entity \(entity_item.name) not found in Resources and has no source_url")
                }
            }
            
            // Images
            for image_item in image_items
            {
                guard let data = image_item.image.pngData() else { continue }
                
                let file_name = image_item.name
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        // MARK: Code
        file_wrappers["Code"] = prepare_listings_wrappers()
        func prepare_listings_wrappers() -> FileWrapper
        {
            var file_wrappers = [String: FileWrapper]()
            
            for listing_item in listing_items
            {
                guard let data = listing_item.text.data(using: .utf8) else { continue }
                
                let file_wrapper = FileWrapper(regularFileWithContents: data)
                
                let file_name = listing_item.name + ".swift"
                file_wrapper.filename = file_name
                file_wrapper.preferredFilename = file_name
                
                file_wrappers[file_name] = file_wrapper
            }
            
            return FileWrapper(directoryWithFileWrappers: file_wrappers)
        }
        
        // MARK: KinematicGroups
        //file_wrappers["KinematicGroups"] =
        //FileWrapper(directoryWithFileWrappers: [:])
        
        return FileWrapper(directoryWithFileWrappers: file_wrappers)
    }
    
    static var new_images_names = [String]()
}
