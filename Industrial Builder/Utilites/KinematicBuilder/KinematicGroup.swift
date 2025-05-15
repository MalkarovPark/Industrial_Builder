//
//  KinematicGroup.swift
//  Industrial Builder
//
//  Created by Artem on 11.04.2024.
//

import Foundation
import IndustrialKit

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
    var type: KinematicGroupType = .portal
    var data = [KinematicElement]()
}

public class KinematicElement: Identifiable, ObservableObject, Equatable, Codable
{
    @Published var name = String()
    @Published var value = Float()

    init(name: String = "", value: Float = 0.0)
    {
        self.name = name
        self.value = value
    }

    public static func == (lhs: KinematicElement, rhs: KinematicElement) -> Bool
    {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.value == rhs.value
    }

    enum CodingKeys: String, CodingKey
    {
        case name
        case value
    }

    required public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        value = try container.decode(Float.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
    }
}

public enum KinematicGroupType: String, Codable, Equatable, CaseIterable
{
    case _6DOF = "6DOF"
    case portal = "Portal"
    
    var design_robot: Robot
    {
        switch self
        {
        case .portal:
            return Robot(
                name: "robot",
                model_controller: Portal_Controller(),
                connector: RobotConnector(),
                scene_name: "KinematicComponents.scnassets/Robots/Portal.scn"
            )
        case ._6DOF:
            return Robot(
                name: "robot",
                model_controller: _6DOF_Controller(),
                connector: RobotConnector(),
                scene_name: "KinematicComponents.scnassets/Robots/6DOF.scn"
            )
        }
    }
    
    var internal_listing_template: String
    {
        switch self 
        {
        case .portal:
            return import_text_data(from: "Internal Portal Controller")
        case ._6DOF:
            return import_text_data(from: "Internal 6DOF Controller")
        }
    }
    
    var external_listing_template: String
    {
        switch self
        {
        case .portal:
            return import_text_data(from: "External Portal Controller")
        case ._6DOF:
            return import_text_data(from: "External 6DOF Controller")
        }
    }
    
    var nodes_names: [String]
    {
        switch self
        {
        case .portal:
            return [
                "base",
                "column",
                "frame",
                "d0",
                "d1",
                "d2"
            ]
        case ._6DOF:
            return [
                "base",
                "column",
                "d0",
                "d1",
                "d2",
                "d3",
                "d4",
                "d5",
                "d6"
            ]
        }
    }
}

public func _6DOFGroupMake(name: String) -> KinematicGroup
{
    var data = [KinematicElement]()
    
    data.append(KinematicElement(name: "L1", value: 160.0))
    data.append(KinematicElement(name: "L2", value: 160.0))
    data.append(KinematicElement(name: "L3", value: 80.0))
    data.append(KinematicElement(name: "L4", value: 160.0))
    data.append(KinematicElement(name: "L5", value: 50.0))
    data.append(KinematicElement(name: "Target", value: 20.0))
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
    data.append(KinematicElement(name: "target", value: 20.0))
    data.append(KinematicElement(name: "limit0_max", value: 320.0))
    data.append(KinematicElement(name: "limit1_max", value: 320.0))
    data.append(KinematicElement(name: "limit2_max", value: 320.0))
    data.append(KinematicElement(name: "Base", value: 160.0))
    
    return KinematicGroup(name: name, type: .portal, data: data)
}
