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
            .onChange(of: app_state.update_gallery_document_notify)
            { _, _ in
                document.images = base_stc.images
            }
            .onChange(of: app_state.update_scenes_document_notify)
            { _, _ in
                document.scenes = base_stc.scenes
            }
            .onChange(of: app_state.update_kinematics_document_notify)
            { _, _ in
                document.kinematic_groups = base_stc.kinematic_groups
            }
            .onChange(of: app_state.update_ima_document_notify)
            { _, _ in
                document.changer_modules = base_stc.changer_modules
            }
    }
}
