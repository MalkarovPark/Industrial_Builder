//
//  DocumentUpdateHandler.swift
//  Industrial Builder
//
//  Created by Artem on 10.03.2024.
//

import Foundation
import SwiftUI

import IndustrialKit

final class DocumentUpdateHandler: ObservableObject
{
    @Published var info_version: Int = 0
    
    @Published var entities_version: Int = 0
    @Published var images_version: Int = 0
    @Published var listings_version: Int = 0
    
    @Published var robots_version: Int = 0
    @Published var tools_version: Int = 0
    @Published var parts_version: Int = 0
    @Published var changers_version: Int = 0
    
    @Published var drop_scenes_version: Int = 0
    @Published var drop_images_version: Int = 0
    @Published var drop_listings_version: Int = 0
    
    public func update_info() { info_version += 1 }
    
    public func update_entities() { entities_version += 1 }
    public func update_images() { images_version += 1 }
    public func update_listings() { listings_version += 1 }
    
    public func update_robots() { robots_version += 1 }
    public func update_tools() { tools_version += 1 }
    public func update_parts() { parts_version += 1 }
    public func update_changers() { changers_version += 1 }
    
    public func drop_update_scenes()
    {
        drop_scenes_version = (drop_scenes_version &+ 1)
    }
    
    public func drop_update_images()
    {
        drop_images_version = (drop_images_version &+ 1)
    }
    
    public func drop_update_listings()
    {
        drop_listings_version = (drop_listings_version &+ 1)
    }
}

struct DocumentUpdateModifier: ViewModifier
{
    @Binding var document: STCDocument
    
    var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    func body(content: Content) -> some View
    {
        content
        // Info
            .onChange(of: document_handler.info_version)
        { _, _ in
            document.package_info = base_stc.package_info
            update_deferred_import()
        }
        
        // Resources
        .onChange(of: document_handler.entities_version)
        { _, _ in
            update_deferred_import()
        }
        .onChange(of: document_handler.images_version)
        { _, _ in
            update_deferred_import()
        }
        .onChange(of: document_handler.listings_version)
        { _, _ in
            document.listing_items = base_stc.listing_items
            update_deferred_import()
        }
        
        // Modules
        .onChange(of: document_handler.robots_version)
        { _, _ in
            document.robot_modules = base_stc.robot_modules
            update_deferred_import()
        }
        .onChange(of: document_handler.tools_version)
        { _, _ in
            document.tool_modules = base_stc.tool_modules
            update_deferred_import()
        }
        .onChange(of: document_handler.parts_version)
        { _, _ in
            document.part_modules = base_stc.part_modules
            update_deferred_import()
        }
        .onChange(of: document_handler.changers_version)
        { _, _ in
            document.changer_modules = base_stc.changer_modules
            update_deferred_import()
        }
        
        // Drop
        .onChange(of: document_handler.drop_scenes_version)
        { _, _ in
            update_deferred_import()
        }
        .onChange(of: document_handler.drop_images_version)
        { _, _ in
            update_deferred_import()
        }
        .onChange(of: document_handler.drop_listings_version)
        { _, _ in
            document.listing_items = base_stc.listing_items
            update_deferred_import()
        }
    }
    
    private func update_deferred_import()
    {
        document.image_items = base_stc.image_items
        document.entity_items = base_stc.entity_items
    }
}

struct DoubleModifier: ViewModifier
{
    @Binding var update_toggle: Bool
    
    func body(content: Content) -> some View
    {
        if update_toggle
        {
            content
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        else
        {
            content
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}
