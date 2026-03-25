//
//  DocumentUpdateHandler.swift
//  Industrial Builder
//
//  Created by Artem on 10.03.2024.
//

import Foundation
import SwiftUI

import IndustrialKit

class DocumentUpdateHandler: ObservableObject
{
    // MARK: Update notifies
    @Published var update_info_document_notify = true
    
    @Published var update_entities_document_notify = true
    @Published var update_images_document_notify = true
    @Published var update_listings_document_notify = true
    
    @Published var update_robots_document_notify = true
    @Published var update_tools_document_notify = true
    @Published var update_parts_document_notify = true
    @Published var update_changers_document_notify = true
    
    // For drop
    @Published var drop_update_scenes_document_notify = 0
    @Published var drop_update_images_document_notify = 0
    @Published var drop_update_listings_document_notify = 0
    
    // MARK: Update functions
    public func document_update_info() { update_info_document_notify.toggle() }
    
    public func document_update_entities() { update_entities_document_notify.toggle() }
    public func document_update_images() { update_images_document_notify.toggle() }
    public func document_update_listings() { update_listings_document_notify.toggle() }
    
    public func document_update_robots() { update_robots_document_notify.toggle() }
    public func document_update_tools() { update_tools_document_notify.toggle() }
    public func document_update_parts() { update_parts_document_notify.toggle() }
    public func document_update_changers() { update_changers_document_notify.toggle() }
    
    // For drop
    public func drop_document_update_scenes() { drop_update_scenes_document_notify = (drop_update_scenes_document_notify + 1) % 5 }
    public func drop_document_update_changersges() { drop_update_images_document_notify = (drop_update_images_document_notify + 1) % 5 }
    public func drop_document_update_listings() { drop_update_listings_document_notify = (drop_update_listings_document_notify + 1) % 5 }
}

struct DocumentUpdateModifier: ViewModifier
{
    @Binding var document: STCDocument
    
    var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    public func body(content: Content) -> some View
    {
        content
            .onChange(of: document_handler.update_info_document_notify)
            { _, _ in
                document.package_info = base_stc.package_info
                //document.package_info.description = base_stc.package_info.description
                //document.package_info.build_modules_lists = base_stc.package_info.build_modules_lists
                update_deferred_import()
            }
            
            // Resources
            .onChange(of: document_handler.update_entities_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.update_images_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.update_listings_document_notify)
            { _, _ in
                document.listing_items = base_stc.listing_items
                
                update_deferred_import()
            }
            
            // Modules
            .onChange(of: document_handler.update_robots_document_notify)
            { _, _ in
                document.robot_modules = base_stc.robot_modules
                
                update_deferred_import()
            }
            .onChange(of: document_handler.update_tools_document_notify)
            { _, _ in
                document.tool_modules = base_stc.tool_modules
                
                update_deferred_import()
            }
            .onChange(of: document_handler.update_parts_document_notify)
            { _, _ in
                document.part_modules = base_stc.part_modules
                
                update_deferred_import()
            }
            .onChange(of: document_handler.update_changers_document_notify)
            { _, _ in
                document.changer_modules = base_stc.changer_modules
                
                update_deferred_import()
            }
            
            // Drop
            .onChange(of: document_handler.drop_update_scenes_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.drop_update_images_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.drop_update_listings_document_notify)
            { _, _ in
                document.listing_items = base_stc.listing_items
                
                update_deferred_import()
            }
    }
    
    private func update_deferred_import()
    {
        document.image_items = base_stc.image_items
        
        //STCDocument.new_scenes_names = base_stc.entities.map { $0.name } // If that data was deferred imported
        document.entity_items = base_stc.entity_items//.map { $0.entity } // document.entities = base_stc.entities.map(\.entity)
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
