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
    //MARK: Update notifies
    @Published var update_scenes_document_notify = true
    @Published var update_images_document_notify = true
    @Published var update_listings_document_notify = true
    @Published var update_kinematics_document_notify = true
    
    @Published var update_parts_document_notify = true
    @Published var update_ima_document_notify = true
    
    //For drop
    @Published var drop_update_scenes_document_notify = 0
    @Published var drop_update_images_document_notify = 0
    @Published var drop_update_listings_document_notify = 0
    
    //MARK: Update functions
    public func document_update_scenes() { update_scenes_document_notify.toggle() }
    public func document_update_images() { update_images_document_notify.toggle() }
    public func document_update_listings() { update_listings_document_notify.toggle() }
    public func document_update_kinematics() { update_kinematics_document_notify.toggle() }
    
    public func document_update_parts() { update_parts_document_notify.toggle() }
    public func document_update_ima() { update_ima_document_notify.toggle() }
    
    //For drop
    public func drop_document_update_scenes() { drop_update_scenes_document_notify = (drop_update_scenes_document_notify + 1) % 5 }
    public func drop_document_update_images() { drop_update_images_document_notify = (drop_update_images_document_notify + 1) % 5 }
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
            .onChange(of: document_handler.update_scenes_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.update_images_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: document_handler.update_listings_document_notify)
            { _, _ in
                document.listings_files_names = base_stc.listings_files_names
                document.listings = base_stc.listings
                
                update_deferred_import()
            }
            .onChange(of: document_handler.update_kinematics_document_notify)
            { _, _ in
                document.kinematic_groups = base_stc.kinematic_groups
                
                update_deferred_import()
            }
            
            .onChange(of: document_handler.update_parts_document_notify)
            { _, _ in
                document.part_modules = base_stc.part_modules
                
                update_deferred_import()
            }
            .onChange(of: document_handler.update_ima_document_notify)
            { _, _ in
                document.changer_modules = base_stc.changer_modules
                
                update_deferred_import()
            }
            
            //Drop
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
                document.listings_files_names = base_stc.listings_files_names
                document.listings = base_stc.listings
                
                update_deferred_import()
            }
        
    }
    
    private func update_deferred_import()
    {
        //update_scenes()
        //update_scripts()
        
        STCDocument.new_images_names = base_stc.images_files_names
        document.images = base_stc.images
        
        STCDocument.new_scenes_names = base_stc.scenes_files_names //If that data was deferred imported
        document.scenes = base_stc.scenes
    }
    
    /*private func update_scenes()
    {
        STCDocument.new_scenes_names = base_stc.scenes_files_names //If that data was deferred imported
        document.scenes = base_stc.scenes
    }*/
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
