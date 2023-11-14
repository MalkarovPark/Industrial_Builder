//
//  StandardTemplateConstruct.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 16.10.2023.
//

import Foundation
import SwiftUI
import SceneKit

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package = STCPackage()
    @Published var images = [UIImage]()
    
    init()
    {
        make_preview()
        make_contents()
    }
    
    func document_view(_ info: STCPackage, images: [UIImage], changer_modules: [ChangerModule], tool_modules: [ToolModule], kinematic_groups: [KinematicGroup])
    {
        self.package = info
        self.images = images
        self.changer_modules = changer_modules
        self.tool_modules = tool_modules
        self.kinematic_groups = kinematic_groups
    }
    
    @Published var kinematic_groups = [KinematicGroup]()
    
    //MARK: Model nodes functions
    @Published var models_nodes = [SCNNode]()
    
    @Published var viewed_model_node = SCNNode()
    
    private func make_preview()
    {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        box.materials = [material]
        viewed_model_node = SCNNode(geometry: box)
    }
    
    private func make_contents()
    {
        for i in 0..<17
        {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
            let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
                    box.materials = [material]
            
            models_nodes.append(SCNNode(geometry: box))
        }
    }
    
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
    
    data.append(KinematicElement(name: "L1", value: 160.0))
    data.append(KinematicElement(name: "L2", value: 160.0))
    data.append(KinematicElement(name: "L3", value: 80.0))
    data.append(KinematicElement(name: "L4", value: 160.0))
    data.append(KinematicElement(name: "L5", value: 40.0))
    data.append(KinematicElement(name: "L6", value: 30.0))
    data.append(KinematicElement(name: "Base", value: 160.0))
    
    return KinematicGroup(name: name, type: ._6DOF, data: data)
}

public func PortalGroupMake(name: String) -> KinematicGroup
{
    var data = [KinematicElement]()
    
    data.append(KinematicElement(name: "frame2", value: 440.0))
    data.append(KinematicElement(name: "limit1_min", value: 80.0))
    data.append(KinematicElement(name: "limit0_min", value: 160.0))
    data.append(KinematicElement(name: "limit2_min", value: 40.0))
    data.append(KinematicElement(name: "target", value: 30.0))
    data.append(KinematicElement(name: "limit0_max", value: 320.0))
    data.append(KinematicElement(name: "limit1_max", value: 320.0))
    data.append(KinematicElement(name: "limit2_max", value: 320.0))
    data.append(KinematicElement(name: "Base", value: 160.0))
    
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
