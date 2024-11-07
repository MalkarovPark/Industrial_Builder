//
//  KinematicGroup.swift
//  Industrial Builder
//
//  Created by Artem on 11.04.2024.
//

import Foundation

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

public struct KinematicElement: Identifiable, Equatable, Codable
{
    public var id = UUID()
    
    var name = String()
    var value = Float()
}

public enum KinematicGroupType: String, Codable, Equatable, CaseIterable
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
