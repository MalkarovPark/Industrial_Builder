//
//  DocumentUpdateHandler.swift
//  Industrial Builder
//
//  Created by Artem on 10.03.2024.
//

import Foundation
import SwiftUI
import IndustrialKit

struct DocumentUpdateHandler: ViewModifier
{
    @Binding var document: STCDocument
    
    var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    
    public func body(content: Content) -> some View
    {
        content
            .onChange(of: app_state.update_images_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: app_state.update_scenes_document_notify)
            { _, _ in
                update_deferred_import()
            }
            .onChange(of: app_state.update_kinematics_document_notify)
            { _, _ in
                document.kinematic_groups = base_stc.kinematic_groups
                document.scenes = base_stc.scenes
                
                update_deferred_import()
            }
            .onChange(of: app_state.update_ima_document_notify)
            { _, _ in
                document.changer_modules = base_stc.changer_modules
                document.scenes = base_stc.scenes
                
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
