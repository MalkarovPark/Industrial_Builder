//
//  StandardTemplateConstruct.swift
//  Industrial Builder
//
//  Created by Artem on 16.10.2023.
//

import Foundation
import SwiftUI
import RealityKit

import IndustrialKit

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package_info = STCPackageInfo()
    
    @Published var entities_loaded = false
    
    init()
    {
        // make_preview()
        // make_contents()
    }
    
    func document_view(_ document: STCDocument, _ bookmark_url: URL? = nil)
    {
        self.package_info = document.package_info
        
        self.image_items = document.image_items
        self.listing_items = document.listing_items
        
        self.robot_modules = document.robot_modules
        self.tool_modules = document.tool_modules
        self.part_modules = document.part_modules
        self.changer_modules = document.changer_modules
        
        load_all_external_entities
        {
            self.entities_loaded = true
        }
        
        self.entities_wrapper = document.entities_wrapper
        
        func load_all_external_entities(_ completion: @escaping () -> Void = {})
        {
            Task
            {
                if let folder_bookmark = get_bookmark(url: bookmark_url)
                {
                    if let loaded_entities = await document.deferred_scene_import(folder_bookmark: folder_bookmark)
                    {
                        await MainActor.run
                        {
                            self.entity_items = loaded_entities
                        }
                    }
                }
                
                completion()
            }
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
    
    // MARK: - Components handling
    // Imported files
    @Published var image_items = [ImageItem]()
    public var image_item_names: [String] { image_items.map { $0.name } }
    
    @Published var listing_items = [ListingItem]()
    public var listing_item_names: [String] { listing_items.map { $0.name } }
    
    @Published var entity_items = [EntityItem]()
    public var entity_item_names: [String] { entity_items.map { $0.name } }
    
    // MARK: - Modules handling
    // Robot modules
    @Published var robot_modules = [RobotModule]()
    public var robot_module_names: [String] { robot_modules.map { $0.name } }
    
    @Published var tool_modules = [ToolModule]()
    public var tool_module_names: [String] { tool_modules.map { $0.name } }
    
    @Published var part_modules = [PartModule]()
    public var part_module_names: [String] { part_modules.map { $0.name } }
    
    @Published var changer_modules = [ChangerModule]()
    public var changer_module_names: [String] { changer_modules.map { $0.name } }
    
    public var any_modules_avaliable: Bool
    {
        return !(robot_modules.isEmpty && tool_modules.isEmpty && part_modules.isEmpty && changer_modules.isEmpty)
    }
    
    // MARK: - UI Info
    @Published var on_building_modules: Bool = false
    @Published var build_progress: Float = 0
    @Published var build_total: Float = 0
    @Published var build_info: String = String()
    
    // Progressbar startup info
    private func set_build_info(list: BuildModulesList, as_internal: Bool)
    {
        // Reset
        build_progress = 0
        build_total = 0
        
        // Package to process count
        if as_internal
        {
            
        }
        else
        {
            build_total += Float(robot_modules.filter { list.robot_module_names.contains($0.name) }.count) * 3
            build_total += Float(tool_modules.filter { list.tool_module_names.contains($0.name) }.count) * 3
            //build_total += Float(part_modules.filter { list.part_module_names.contains($0.name) }.count) * 0
            build_total += Float(changer_modules.filter { list.changer_module_names.contains($0.name) }.count) * 2
        }
    }
    
    // MARK: - Code generation functions
    public func misc_code_process(type: MiscCodeGenerationFunction, input: String = String()) -> String
    {
        switch type
        {
        case .blank:
            return ""
        case .clipboard:
            return get_clipboard_string()
        }
    }
    
    private func get_clipboard_string() -> String
    {
        #if os(macOS)
        return NSPasteboard.general.string(forType: .string) ?? ""
        #else
        return UIPasteboard.general.string ?? ""
        #endif
    }
    
    // MARK: - MBK
    // Makes a Swift package project with IndustrialKit framework import (blank project)
    public func make_industrial_app_project(name: String, to url: URL, remove_tmp_from: URL?)
    {
        internal_files_store(["MakeIndustrialApp.command", "PBuild.command"], to: url)
        
        do
        {
            #if os(macOS)
            try perform_terminal_command("cd '\(url.path)' && ./MakeIndustrialApp.command '\(name)'")
            #endif
            
            // Remove unused template blank file
            if let remove_tmp_from = remove_tmp_from
            {
                do
                {
                    if FileManager.default.fileExists(atPath: remove_tmp_from.path)
                    {
                        try FileManager.default.removeItem(at: remove_tmp_from)
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
        }
        catch
        {
            print(error.localizedDescription)
            /*DispatchQueue.main.async
            {
                self.build_info += "\nError during external compilation: \(error.localizedDescription)"
            }*/
        }
    }
    
    // Makes a Swift package project with IndustrialKit framework import (from file)
    public func make_simple_app(name: String, data: String, to url: URL)
    {
        remove_file(at: url.appendingPathComponent(name)) // Remove empty project target file
        
        make_files(
            by: app_package_pattern(
                name: URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent,
                data: data
            ),
            to: url
        )
        
        /*internal_files_store(["MakeIndustrialApp.command"], to: url)
        
        #if os(macOS)
        do
        {
            try perform_terminal_command("cd '\(url.path)' && ./ListingToProject.command --clear '\(file_name)'")
        }
        catch
        {
            
        }
        #endif*/
    }
    
    private func remove_file(at url: URL)
    {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        if FileManager.default.fileExists(atPath: url.path)
        {
            do
            {
                try FileManager.default.removeItem(at: url)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    // Store the Modules Building Kit
    public func store_mbk(to url: URL)
    {
        internal_files_store(
            [
                "MakeIndustrialApp.command",
                "ListingToProject.command",
                "ProjectToProgram.command",
                "BuildModuleProgram.command"
            ],
            to: url
        )
    }
    
    // Store text files from the app itself to external files
    private func internal_files_store(_ file_names: [String], to folder_url: URL)
    {
        for file_name in file_names
        {
            guard let file_url = Bundle.main.url(forResource: file_name, withExtension: nil) else { continue }
            let destination_url = folder_url.appendingPathComponent(file_name)
            
            do
            {
                // If file already exists at destination — remove it first
                if FileManager.default.fileExists(atPath: destination_url.path)
                {
                    try FileManager.default.removeItem(at: destination_url)
                }

                // Copy new file from app bundle
                try FileManager.default.copyItem(at: file_url, to: destination_url)
            }
            catch
            {
                print("Failed to copy \(file_name): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Export Modules
    // Builds modules in separated files.
    public func export_modules(list: BuildModulesList, to folder_url: URL, option: ModuleExportOption)
    {
        // No-build options
        if option == .internal_modules { make_internal_modules(list: list, to: folder_url); return }
        if option == .mbk_only { store_mbk(to: folder_url); return }
        
        // Build external modules
        DispatchQueue.global(qos: .background).async
        {
            self.set_build_info(list: list, as_internal: false)
            self.on_building_modules = true
            
            guard folder_url.startAccessingSecurityScopedResource()
            else
            {
                DispatchQueue.main.async
                {
                    self.on_building_modules = false
                }
                return
            }
            
            DispatchQueue.main.async
            {
                self.build_info = "Building modules files"
            }
            self.build_modules_files(list: list, to: folder_url, option: option)
            
            folder_url.stopAccessingSecurityScopedResource()
            
            DispatchQueue.main.async
            {
                if !self.compilation_cancelled
                {
                    self.build_info = "Finished"
                }
                else
                {
                    self.build_info = "Canceled"
                }
            }
            
            let work_item = DispatchWorkItem
            {
                if self.compilation_cancelled { self.compilation_cancelled = false }
                self.on_building_modules = false
                /*DispatchQueue.main.async
                {
                    if self.compilation_cancelled { self.compilation_cancelled = false }
                    self.on_building_modules = false
                }*/
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: work_item)
        }
    }
    
    private func build_modules_files(list: BuildModulesList, to folder_url: URL, option: ModuleExportOption)
    {
        // Store compilation kit for external modules build
        internal_files_store(
            [
                "ListingToProject.command",
                "ProjectToProgram.command",
                "BuildModulePrograms.command"
            ],
            to: folder_url
        )
        
        // Builds modules in separated files
        let filtered_robot_modules = robot_modules.filter { list.robot_module_names.contains($0.name) }
        for robot_module in filtered_robot_modules
        {
            if !compilation_cancelled
            {
                build_external_module_file(module: robot_module, to: folder_url, option: option) // Create robot module package
                #if os(macOS)
                perform_external_compilation(module: robot_module, to: folder_url, option: option) // Compile programs
                #endif
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_tool_modules = tool_modules.filter { list.tool_module_names.contains($0.name) }
        for tool_module in filtered_tool_modules
        {
            if !compilation_cancelled
            {
                build_external_module_file(module: tool_module, to: folder_url, option: option) // Create tool module package
                #if os(macOS)
                perform_external_compilation(module: tool_module, to: folder_url, option: option) // Compile programs
                #endif
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_part_modules = part_modules.filter { list.part_module_names.contains($0.name) }
        for part_module in filtered_part_modules
        {
            if !compilation_cancelled
            {
                build_external_module_file(module: part_module, to: folder_url, option: option) // Create part module package
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_changer_modules = changer_modules.filter { list.changer_module_names.contains($0.name) }
        for changer_module in filtered_changer_modules
        {
            if !compilation_cancelled
            {
                build_external_module_file(module: changer_module, to: folder_url, option: option) // Create changer module package
                #if os(macOS)
                perform_external_compilation(module: changer_module, to: folder_url, option: option) // Compile programs
                #endif
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
    }
    
    public var entities_wrapper: FileWrapper?
    
    private func build_external_module_file(module: IndustrialModule, to folder_url: URL, option: ModuleExportOption)
    {
        #if os(macOS)
        if option == .build_from_projects || option == .projects_to_programs { return } // Skip modules files build for only compilation/conversion export type
        #endif
        
        do
        {
            let module_path = folder_url.appendingPathComponent("\(module.name).\(module.extension_name)")
            
            // Remove existing file or directory if it already exists
            if FileManager.default.fileExists(atPath: module_path.path)
            {
                try FileManager.default.removeItem(at: module_path)
            }
            
            // Now safely create the folder
            let module_url = try make_folder("\(module.name).\(module.extension_name)", module_url: folder_url)
            
            // Info file store
            try make_info_file(url: module_url)
            
            // Code folder store
            try make_code_folder(url: module_url)
            
            // Resources folder store
            try make_resources_folder(url: module_url)
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
        
        func make_info_file(url: URL) throws // For external module
        {
            let info_data = module.json_data()
            let info_url = url.appendingPathComponent("Info")
            try info_data.write(to: info_url)
        }
        
        func make_code_folder(url: URL) throws
        {
            guard module is RobotModule || module is ToolModule else { return } // Tool, changer and part module has no external code...
            
            let code_url = try make_module_folder("Code", module_url: url, module_name: module.name)
            
            switch module
            {
            case let module as RobotModule:
                try code_files_store(code_items: ["Connector": module.connector_code], to: code_url)
            case let module as ToolModule:
                try code_files_store(code_items: ["Connector": module.connector_code], to: code_url)
            default:
                break
            }
        }
        
        func make_resources_folder(url: URL) throws
        {
            guard let entity_file_name =
                (module as? RobotModule)?.entity_file_name ??
                (module as? ToolModule)?.entity_file_name ??
                (module as? PartModule)?.entity_file_name
            else { return }
            
            guard let entity_file_item =
                entity_items.first(where: { $0.name == entity_file_name })
            else { return }
            
            guard let scene_files = entities_wrapper?.fileWrappers else { return }
            
            let destination_url = url.appendingPathComponent("Scene.usdz")
            
            if let source_url = entity_file_item.source_url
            {
                try FileManager.default.copyItem(at: source_url, to: destination_url) // External imported
            }
            else
            {
                let wrapper_key = entity_file_item.name.hasSuffix(".usdz") ? entity_file_item.name : entity_file_item.name + ".usdz"
                
                if let wrapper = scene_files[wrapper_key],
                   let data = wrapper.regularFileContents
                {
                    try data.write(to: destination_url) // From STC package
                }
                else
                {
                    print("Warning: entity \(entity_file_item.name) not found in Resources and has no source_url")
                }
            }
            
            /*let file_name_with_ext =
                entity_file_item.name.hasSuffix(".usdz")
                ? entity_file_item.name
                : entity_file_item.name + ".usdz"
            
            let destination_url = url.appendingPathComponent(file_name_with_ext)
            
            if let source_url = entity_file_item.source_url
            {
                try FileManager.default.copyItem(at: source_url, to: destination_url) // External imorted
            }
            else if let wrapper = scene_files[file_name_with_ext],
                    let data = wrapper.regularFileContents
            {
                try data.write(to: destination_url) // From STC package
            }
            else
            {
                print("Warning: entity \(entity_file_item.name) not found in Resources and has no source_url")
            }*/
        }
        
        func make_module_folder(_ folder_name: String, module_url: URL, module_name: String) throws -> URL
        {
            let folder_url = module_url.appendingPathComponent(folder_name)
            
            if FileManager.default.fileExists(atPath: folder_url.path)
            {
                try FileManager.default.removeItem(at: folder_url)
            }
            try FileManager.default.createDirectory(at: folder_url, withIntermediateDirectories: true, attributes: nil)
            
            return folder_url
        }
        
        func code_files_store(code_items: [String: String], to code_url: URL) throws // Store code items to listings
        {
            for code_item in code_items // Store external files without parameters inject
            {
                let code_item_url = code_url.appendingPathComponent("\(code_item.key).swift")
                try code_item.value.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    // MARK: Compilation handling
    private var compilation_cancelled = false
    #if os(macOS)
    private var compilation_process: Process? = nil
    
    private func perform_external_compilation(module: IndustrialModule, to folder_url: URL, option: ModuleExportOption)
    {
        if option == .no_build { return }
        
        var command_line = "cd '\(folder_url.path)' && ./"
        var module_package_name = module.name
        
        switch module
        {
        case is RobotModule:
            module_package_name += ".robot"
        case is ToolModule:
            module_package_name += ".tool"
        case is PartModule:
            module_package_name += ".part"
        case is ChangerModule:
            module_package_name += ".changer"
        default:
            return
        }
        
        module_package_name = module_package_name.replacingOccurrences(of: " ", with: "\\ ")
        
        switch option
        {
        case .programs_only:
            command_line += "BuildModulePrograms.command --programs "
        case .projects_and_programs:
            command_line += "BuildModulePrograms.command --projects-programs "
        case .projects_only:
            command_line += "BuildModulePrograms.command --projects "
        case .build_from_projects:
            command_line += "BuildModulePrograms.command "
        case .projects_to_programs:
            command_line += "BuildModulePrograms.command --clear "
        default:
            return
        }
        
        command_line += module_package_name
        
        do
        {
            self.compilation_cancelled = false
            
            let task = Process()
            let pipe = Pipe()
            
            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["-c", command_line]
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            
            self.compilation_process = task
            
            let handle = pipe.fileHandleForReading
            handle.readabilityHandler =
            { fileHandle in
                let data = fileHandle.availableData
                if data.isEmpty { return }
                if let output = String(data: data, encoding: .utf8)
                {
                    let lines = output.components(separatedBy: .newlines)
                    if let last_line = lines.last(where: { !$0.isEmpty })
                    {
                        DispatchQueue.main.async
                        {
                            self.build_info = last_line
                            self.build_progress += 1
                            //print("\(self.build_progress) in \(self.build_total)")
                        }
                    }
                }
            }
            
            try task.run()
            task.waitUntilExit()
            handle.readabilityHandler = nil
            self.compilation_process = nil
            
            if !self.compilation_cancelled
            {
                DispatchQueue.main.async
                {
                    self.build_info += "\nExternal code compilation finished."
                }
            }
        }
        catch
        {
            DispatchQueue.main.async
            {
                self.build_info += "\nCompilation error: \(error.localizedDescription)"
            }
        }
    }
    #endif
    
    public func cancel_build()
    {
        #if os(macOS)
        if let process = compilation_process
        {
            compilation_cancelled = true
            process.terminate()
            compilation_process = nil
        }
        #else
        compilation_cancelled = true
        #endif
    }
    
    // MARK: - Build Industrial App
    // Builds application project to compile with internal modules.
    public func make_industrial_project(
        name: String,
        list: BuildModulesList,
        to folder_url: URL,
        option: ProjectExportOption
    )
    {
        remove_file(at: folder_url.appendingPathComponent(name)) // Remove empty project target file
        
        switch option
        {
        case .swift_playground:
            make_files(
                by: swift_playground_pattern(
                    name: name,
                    modules_func:
                        { url in
                            self.make_internal_modules(
                                list: self.package_info.build_modules_list,
                                to: url
                            )
                        }
                ),
                to: folder_url
            )
        case .xcode_project:
            make_files(
                by: xcode_project_pattern(
                    name: name,
                    modules_func:
                        { url in
                            self.make_internal_modules(
                                list: self.package_info.build_modules_list,
                                to: url
                            )
                        }
                ),
                to: folder_url
            )
        }
    }
    
    //MARK: Internal Modules Packaging
    public func make_internal_modules(list: BuildModulesList, to folder_url: URL)
    {
        guard !list.is_empty else { return }
        
        DispatchQueue.global(qos: .background).async
        {
            DispatchQueue.main.async
            {
                self.set_build_info(list: list, as_internal: true)
                self.on_building_modules = true
            }
            
            do
            {
                // Internal modules folder
                guard folder_url.startAccessingSecurityScopedResource() else
                {
                    DispatchQueue.main.async
                    {
                        self.on_building_modules = false
                    }
                    return
                }
                
                let package_folder_url = try self.make_folder("Modules", module_url: folder_url)
                
                self.make_internal_modules_files(list: list, to: package_folder_url)
                
                // Make Internal Modules List
                var list_code = import_text_data(from: "List")
                
                let placeholders = [
                    ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Robot Modules@*//*@END_MENU_TOKEN@*/", list.robot_module_names, "_RobotModule"),
                    ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Tool Modules@*//*@END_MENU_TOKEN@*/", list.tool_module_names, "_ToolModule"),
                    ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Part Modules@*//*@END_MENU_TOKEN@*/", list.part_module_names, "_PartModule"),
                    ("/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Changer Modules@*//*@END_MENU_TOKEN@*/", list.changer_module_names, "_ChangerModule")
                ]
                
                for (placeholder, names, suffix) in placeholders
                {
                    let formatted_names = names
                        .map { "\($0.code_correct_format)\(suffix)" }
                        .joined(separator: ",\n        ")
                    
                    list_code = list_code.replacingOccurrences(
                        of: placeholder,
                        with: formatted_names,
                        options: .literal,
                        range: nil
                    )
                }
                
                try list_code.write(to: package_folder_url.appendingPathComponent("List.swift"), atomically: true, encoding: .utf8)
                
                folder_url.stopAccessingSecurityScopedResource()
                
                DispatchQueue.main.async
                {
                    self.build_info = "Finished"
                }
                
                let work_item = DispatchWorkItem
                {
                    DispatchQueue.main.async
                    {
                        self.on_building_modules = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: work_item)
            }
            catch
            {
                print(error.localizedDescription)
                DispatchQueue.main.async
                {
                    self.on_building_modules = false
                }
            }
        }
    }
    
    // Build modules
    private func make_internal_modules_files(list: BuildModulesList, to folder_url: URL)
    {
        // Builds modules in separated files
        let filtered_robot_modules = robot_modules.filter { list.robot_module_names.contains($0.name) }
        for robot_module in filtered_robot_modules
        {
            if !compilation_cancelled
            {
                make_internal_module_file(module: robot_module, to: folder_url) // Create robot module package
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_tool_modules = tool_modules.filter { list.tool_module_names.contains($0.name) }
        for tool_module in filtered_tool_modules
        {
            if !compilation_cancelled
            {
                make_internal_module_file(module: tool_module, to: folder_url) // Create tool module package
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_part_modules = part_modules.filter { list.part_module_names.contains($0.name) }
        for part_module in filtered_part_modules
        {
            if !compilation_cancelled
            {
                make_internal_module_file(module: part_module, to: folder_url) // Create part module package
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
        
        let filtered_changer_modules = changer_modules.filter { list.changer_module_names.contains($0.name) }
        for changer_module in filtered_changer_modules
        {
            if !compilation_cancelled
            {
                make_internal_module_file(module: changer_module, to: folder_url) // Create changer module package
                //self.build_progress += 1
            }
            else
            {
                break
            }
        }
    }
    
    // MARK: Build module file
    private func make_internal_module_file(module: IndustrialModule, to folder_url: URL)
    {
        do
        {
            let module_path = folder_url.appendingPathComponent("\(module.name).\(module.extension_name)")
            
            // Remove existing file or directory if it already exists
            if FileManager.default.fileExists(atPath: module_path.path)
            {
                try FileManager.default.removeItem(at: module_path)
            }
            
            // Now safely create the folder
            let module_url = try make_folder("\(module.name).\(module.extension_name)", module_url: folder_url)
            
            // Info file store
            try make_info_file(url: module_url)
            
            // Resources folder store
            try make_resources_folder(url: module_url)
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
        
        func make_info_file(url: URL) throws
        {
            switch module
            {
            case let module as RobotModule:
                try make_module_listing(by: module, to: url)
            case let module as ToolModule:
                try make_module_listing(by: module, to: url)
            case let module as PartModule:
                try make_module_listing(by: module, to: url)
            case let module as ChangerModule:
                try make_module_listing(by: module, to: url)
            default:
                break
            }
            
            func make_module_listing(by module: RobotModule, to: URL) throws
            {
                let code_item_url = url.appendingPathComponent("\(module.name)_RobotModule.swift")
                
                var code = import_text_data(from: "RobotModuleDeclaration")
                
                // Set module name
                code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
                code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
                
                // Default Origin Position
                code = code.replacingOccurrences(
                    of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=(x: Float, y: Float, z: Float, r: Float, p: Float, w: Float)@*/(0, 0, 0, 0, 0, 0)/*@END_MENU_TOKEN@*/",
                    with: "(x: \(module.default_origin_position.x), y: \(module.default_origin_position.y), z: \(module.default_origin_position.z), r: \(module.default_origin_position.r), p: \(module.default_origin_position.p), w: \(module.default_origin_position.w))"
                )
                
                // Origin Shift
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=(x: Float, y: Float, z: Float)@*/(0, 0, 0)/*@END_MENU_TOKEN@*/", with: "(x: \(module.origin_shift.x), y: \(module.origin_shift.y), z: \(module.origin_shift.z))")
                
                // End Entity Name
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=String@*/String()/*@END_MENU_TOKEN@*/", with: "\(module.end_entity_name.isEmpty ? "String()" : module.end_entity_name)")
                
                // Connected nodes names
                let nodes_names = module.entity_names.map { "        \"\($0)\"" }.joined(separator: ",\n")
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=entity_names@*//*@END_MENU_TOKEN@*/", with: nodes_names)
                
                // Set model controller code
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=model_controller_code@*//*@END_MENU_TOKEN@*/", with: module.model_controller_code)
                
                // Set connector code
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=connector_code@*//*@END_MENU_TOKEN@*/", with: module.connector_code)
                
                try code.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
            
            func make_module_listing(by module: ToolModule, to: URL) throws
            {
                let code_item_url = url.appendingPathComponent("\(module.name)_ToolModule.swift")
                
                var code = import_text_data(from: "ToolModuleDeclaration")
                
                // Set module name
                code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
                code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
                
                // Operation codes
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=operation_codes@*//*@END_MENU_TOKEN@*/", with: opcode_data_to_code(module.codes))
                func opcode_data_to_code(_ data: [OperationCodeInfo]) -> String
                {
                    return """
                    \(data.map
                    {
                        ".init(value: \($0.value), name: \"\($0.name)\", symbol_name: \"\($0.symbol_name)\", description: \"\($0.description)\")"
                    }
                    .joined(separator: ",\n        "))
                    """
                }
                
                // Connected nodes names
                let nodes_names = module.entity_names.map { "        \"\($0)\"" }.joined(separator: ",\n")
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=entity_names@*//*@END_MENU_TOKEN@*/", with: nodes_names)
                
                // Set model controller code
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=model_controller_code@*//*@END_MENU_TOKEN@*/", with: module.model_controller_code)
                
                // Set connector code
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=connector_code@*//*@END_MENU_TOKEN@*/", with: module.connector_code)
                
                try code.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
            
            func make_module_listing(by module: PartModule, to: URL) throws
            {
                let code_item_url = url.appendingPathComponent("\(module.name)_PartModule.swift")
                
                var code = import_text_data(from: "InternalPartModuleDeclaration")
                
                // Set module name
                code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
                code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
                
                try code.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
            
            func make_module_listing(by module: ChangerModule, to: URL) throws
            {
                let code_item_url = url.appendingPathComponent("\(module.name)_ChangerModule.swift")
                
                var code = import_text_data(from: "ChangerModuleDeclaration")
                
                // Set module name
                code = code.replacingOccurrences(of: "<#Name#>", with: module.name.code_correct_format)
                code = code.replacingOccurrences(of: "<#ModuleName#>", with: module.name)
                
                // Set function code
                code = code.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=changer_function_code@*//*@END_MENU_TOKEN@*/", with: module.changer_function_code)
                
                try code.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
        }
        
        func make_code_folder(url: URL) throws
        {
            guard module is RobotModule || module is ToolModule else { return } // Part and Changer module has no external code...
            
            let code_url = try make_module_folder("Code", module_url: url, module_name: module.name)
            
            switch module
            {
            case let module as RobotModule:
                try make_code_files(module: module, to: code_url)
            case let module as ToolModule:
                try make_code_files(module: module, to: code_url)
            //case let module as PartModule:
                //try make_code_files(module: module, to: code_url)
            //case let module as ChangerModule:
                //try make_code_files(module: module, to: code_url)
            default:
                break
            }
            
            func make_code_files(module: RobotModule, to url: URL) throws
            {
                
            }
            
            func make_code_files(module: ToolModule, to url: URL) throws
            {
                
            }
            
            /*func make_code_files(module: PartModule, to url: URL) throws
            {
                
            }*/
            
            /*func make_code_files(module: ChangerModule, to url: URL) throws
            {
                
            }*/
            
            /*var updated_code_items = module.code_items
            
            // Inject parameters in code items
            if module is RobotModule || module is ToolModule
            {
                inject_controller_parameters(code: &updated_code_items["Controller"], module: module)
                inject_connector_parameters(code: &updated_code_items["Connector"], module: module)
            }
            
            updated_code_items = updated_code_items.reduce(into: [String: String]())
            { result, entry in
                result["\(module.name)_\(entry.key)"] = entry.value
            }
            
            try code_files_store(code_items: updated_code_items, to: code_url)*/
        }
        
        func make_resources_folder(url: URL) throws
        {
            guard let entity_file_name =
                (module as? RobotModule)?.entity_file_name ??
                (module as? ToolModule)?.entity_file_name ??
                (module as? PartModule)?.entity_file_name
            else { return }
            
            guard let entity_file_item =
                entity_items.first(where: { $0.name == entity_file_name })
            else { return }
            
            guard let scene_files = entities_wrapper?.fileWrappers else { return }
            
            let destination_url = url.appendingPathComponent("\(module.name).\(module.extension_name).Scene.usdz")
            
            if let source_url = entity_file_item.source_url
            {
                try FileManager.default.copyItem(at: source_url, to: destination_url) // External imported
            }
            else
            {
                let wrapper_key = entity_file_item.name.hasSuffix(".usdz") ? entity_file_item.name : entity_file_item.name + ".usdz"
                
                if let wrapper = scene_files[wrapper_key],
                   let data = wrapper.regularFileContents
                {
                    try data.write(to: destination_url) // From STC package
                }
                else
                {
                    print("Warning: entity \(entity_file_item.name) not found in Resources and has no source_url")
                }
            }
        }
        
        func make_module_folder(_ folder_name: String, module_url: URL, module_name: String) throws -> URL
        {
            let folder_url = module_url.appendingPathComponent("\(module_name)_\(folder_name)")
            
            if FileManager.default.fileExists(atPath: folder_url.path)
            {
                try FileManager.default.removeItem(at: folder_url)
            }
            try FileManager.default.createDirectory(at: folder_url, withIntermediateDirectories: true, attributes: nil)
            
            return folder_url
        }
        
        func code_files_store(code_items: [String: String], to code_url: URL) throws // Store code items to listings
        {
            for code_item in code_items // Store external files without parameters inject
            {
                let code_item_url = code_url.appendingPathComponent("\(code_item.key).swift")
                try code_item.value.write(to: code_item_url, atomically: true, encoding: .utf8)
            }
        }
        
        // MARK: OLD
        func inject_controller_parameters(code: inout String?, module: IndustrialModule) // Inject model controller parameters (nodes names) to internal code file
        {
            var nodes_names = String()
            
            /*if let robot_module = module as? RobotModule
            {
                nodes_names = robot_module.nodes_names.map { "\"\($0)\"" }.joined(separator: ",\n            ")
            }
            
            if let tool_odule = module as? ToolModule
            {
                nodes_names = tool_odule.nodes_names.map { "\"\($0)\"" }.joined(separator: ",\n            ")
            }*/
            
            code = code?.replacingOccurrences(of: "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=nodes_names@*//*@END_MENU_TOKEN@*/", with: nodes_names)
        }
        
        func inject_connector_parameters(code: inout String?, module: IndustrialModule) // Inject model connection parameters to internal code file
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
        
        // Module code (for internal)
        
        
        // MARK: OLD
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

// MARK: - Enums
public enum ProjectExportOption: String, Equatable, CaseIterable
{
    case swift_playground = "Swift Playground"
    case xcode_project = "Xcode Project"
}

public enum ModuleExportOption: String, Equatable, CaseIterable
{
    #if os(macOS)
    case projects_and_programs = "Build To Projects and Programs"
    case programs_only = "Build To Programs Only"
    case projects_only = "Build To Projects Only"
    case build_from_projects = "Build Existing Projects To Programs"
    case projects_to_programs = "Turn Existing Projects To Programs"
    
    case divider = "_"
    #endif
    case no_build = "No Build (Listings Only)"
    
    case internal_modules = "Make Internal Modules for Project"
    case mbk_only = "Module Building Kit Only"
}

public enum MiscCodeGenerationFunction: String, Equatable, CaseIterable
{
    case blank = "Blank"
    case clipboard = "Clipboard"
    
    var symbol_name: String
    {
        switch self
        {
        case .blank:
            return "rays"
        case .clipboard:
            return "document.on.clipboard"
        }
    }
}

extension ConnectionParameter
{
    public var code_text: String
    {
        let value_string: String
        switch value
        {
        case let string_value as String:
            value_string = "\"\(string_value)\""
        case let bool_value as Bool:
            value_string = "\(bool_value)"
        case let int_value as Int:
            value_string = "\(int_value)"
        case let float_value as Float:
            value_string = "Float(\(float_value))"
        default:
            value_string = "nil"
        }
        return ".init(name: \"\(name)\", value: \(value_string))"
    }
}
