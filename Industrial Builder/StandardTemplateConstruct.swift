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
    
    @Published var kinematic_groups = [KinematicGroup]()
    
    //MARK: Changer modules
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

//MARK: - Structures
//MARK: App Modules
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

//MARK: Kinematic
public struct KinematicGroup: Identifiable, Equatable, Codable, Hashable
{
    public var id = UUID()
    
    public static func == (lhs: KinematicGroup, rhs: KinematicGroup) -> Bool
    {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
    }
    
    var name = String()
    var type: KinematicGroupTypes = .portal
    var data = [KinematicElement]()
}

public struct KinematicElement: Identifiable, Equatable, Codable
{
    public var id = UUID()
    
    var name = String()
    var value = Float()
    
    //var joints = [KinematicJoint]() //First two used...
}

/*public enum KinematicJoint: String, Codable, Equatable, CaseIterable
{
    case revolute = "Revolute"
    case prismatic = "Prismatic"
    case cardan = "Cardan"
    case screw = "Screw"
    case planar = "Planar"
    case cylindrical = "Cylindrical"
    case parallel = "Parallel"
    case spherical = "Spherical"
    case slider = "Slider"
    case rotational = "Rotational"
    case linear = "Linear"
    case universal = "Universal"
}*/

public enum KinematicGroupTypes: String, Codable, Equatable, CaseIterable
{
    //case none = "None"
    case _6DOF = "6DOF"
    case portal = "Portal"
}

public func _6DOFGroupMake(name: String) -> KinematicGroup
{
    var data = [KinematicElement]()
    
    for i in 0...7
    {
        data.append(KinematicElement(name: "L\(i)", value: 20.0))
    }
    
    return KinematicGroup(name: name, type: ._6DOF, data: data)
}

public func PortalGroupMake(name: String) -> KinematicGroup
{
    var data = [KinematicElement]()
    
    for i in 0...9
    {
        data.append(KinematicElement(name: "L\(i)", value: 20.0))
    }
    
    return KinematicGroup(name: name, type: .portal, data: data)
}

//MARK: Package
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
