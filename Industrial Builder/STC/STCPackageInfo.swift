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

public struct STCPackageInfo: Codable
{
    var id: UUID
    var description: String
    var images_data: [Data?] = [Data]()
    
    var build_modules_lists = [BuildModulesList]()
    
    init(id: UUID = .init(), title: String = .init(), description: String = .init(), images_data: [Data?] = [Data](), build_modules_lists: [BuildModulesList] = [BuildModulesList]())
    {
        self.id = id
        self.description = description
        self.images_data = images_data
    }
    
    // /Workspace object preview image.
    var gallery: [UIImage]
    {
        get
        {
            var gallery = [UIImage]()
            for image_data in images_data
            {
                gallery.append(UIImage(data: image_data ?? Data()) ?? UIImage())
            }
            
            return gallery
        }
        set
        {
            images_data.removeAll()
            for image in newValue
            {
                images_data.append(image.pngData() ?? Data())
            }
        }
    }
    
    // /Removes all images from gallery.
    mutating func clear_gallery()
    {
        images_data.removeAll()
    }
    
    // /Build modules lists names.
    public var build_modules_lists_names: [String]
    {
        var names = [String]()
        for build_modules_list in build_modules_lists
        {
            names.append(build_modules_list.name)
        }
        
        return names
    }
}

public struct BuildModulesList: Codable, Hashable
{
    var name = String()
    
    var robot_modules_names = [String]()
    var tool_modules_names = [String]()
    var part_modules_names = [String]()
    
    var changer_modules_names = [String]()
}
