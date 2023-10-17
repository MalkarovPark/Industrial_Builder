//
//  StandardTemplateConstruct.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 16.10.2023.
//

import Foundation
import SwiftUI

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package = STCPackage()
    @Published var images = [UIImage]()
    
    init()
    {
        
    }
    
    func document_view(_ info: STCPackage, images: [UIImage], changer_modules: [ChangerModule], tool_modules: [ToolModule])
    {
        self.package = info
        self.images = images
        self.changer_modules = changer_modules
        self.tool_modules = tool_modules
    }
    
    //MARK: Changer modules
    @Published var changer_modules = [ChangerModule]()
    
    //MARK: Robot modules
    
    //MARK: Tool modules
    @Published var tool_modules = [ToolModule]()
    
    @Published var selected_tool_module_name = ""
    
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

public struct ChangerModule: Equatable, Codable
{
    var name = ""
    var code = ""
}

public struct ToolModule: Equatable, Codable
{
    var name = ""
    
    var operation_codes = [OperationCode]()
    
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
    var disconnect = ""
    var other = ""
    
    var statistics = StatisticsFunctionsData()
}

public struct StatisticsFunctionsData: Equatable, Codable
{
    var chart_code = ""
    var chart_code_clear = ""
    
    var state_code = ""
    var state_code_clear = ""
    
    var other_code = ""
}

public struct OperationCode: Equatable, Codable
{
    var value = 0
    var name = ""
    var symbol = "questionmark"
    
    //var code = ""
    var controller_code = ""
    var connector_code = ""
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

public struct STCPackage: Codable
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
