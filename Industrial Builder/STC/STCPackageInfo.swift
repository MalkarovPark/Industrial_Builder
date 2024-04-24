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
    var title: String
    var description: String
    var images_data: [Data?] = [Data]()
    
    init(id: UUID = .init(), title: String = .init(), description: String = .init(), images_data: [Data?] = [Data]())
    {
        self.id = id
        self.title = title
        self.description = description
        self.images_data = images_data
    }
    
    ///Workspace object preview image.
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
    
    mutating func clear_gallery()
    {
        images_data.removeAll()
    }
}
