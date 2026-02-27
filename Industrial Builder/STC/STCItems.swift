//
//  STCItems.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 27.02.2026.
//

import Foundation
import RealityKit
import IndustrialKit
#if !os(macOS)
import UIKit
#endif

// MARK: - Scene item wrapper
public class EntityItem: Identifiable, Equatable, ObservableObject
{
    public let id: UUID = UUID()
    
    public static func == (lhs: EntityItem, rhs: EntityItem) -> Bool
    {
        lhs.id == rhs.id
    }
    
    public var name: String
    public var entity: Entity
    
    public var source_url: URL?
    
    public init(
        name: String,
        entity: Entity,
        
        source_url: URL? = nil
    )
    {
        self.name = name
        self.entity = entity
        
        self.source_url = source_url
    }
}

// MARK: - Image item wrapper
public class ImageItem: Identifiable, Equatable, ObservableObject
{
    public let id: UUID = UUID()
    
    public static func == (lhs: ImageItem, rhs: ImageItem) -> Bool
    {
        lhs.id == rhs.id
    }
    
    public var name: String
    public var image: UIImage
    
    //public var source_url: URL?
    
    public init(
        name: String,
        image: UIImage,
        //source_url: URL? = nil
    )
    {
        self.name = name
        self.image = image
        //self.source_url = source_url
    }
}

// MARK: - Listing item wrapper
public class ListingItem: Identifiable, Equatable, ObservableObject
{
    public let id: UUID = UUID()
    
    public static func == (lhs: ListingItem, rhs: ListingItem) -> Bool
    {
        lhs.id == rhs.id
    }
    
    public var name: String
    public var text: String
    
    //public var source_url: URL?
    
    public init(
        name: String,
        text: String,
        //source_url: URL? = nil
    )
    {
        self.name = name
        self.text = text
        //self.source_url = source_url
    }
}
