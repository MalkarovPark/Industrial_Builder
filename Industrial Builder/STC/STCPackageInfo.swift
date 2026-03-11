//
//  STCPackageInfo.swift
//  Industrial Builder
//
//  Created by Artem on 11.04.2024.
//

import Foundation
#if !os(macOS)
import UIKit
#endif

import IndustrialKit

public struct STCPackageInfo: Codable
{
    var id: UUID
    var description: String
    var images_data: [Data?] = [Data]()
    
    var build_modules_list = BuildModulesList()
    
    init(id: UUID = .init(), title: String = .init(), description: String = .init(), images_data: [Data?] = [Data](), build_modules_lists: [BuildModulesList] = [BuildModulesList]())
    {
        self.id = id
        self.description = description
        self.images_data = images_data
    }
}

public struct BuildModulesList: Codable, Hashable
{
    var robot_modules_names = [String]()
    var tool_modules_names = [String]()
    var part_modules_names = [String]()
    
    var changer_modules_names = [String]()
}
