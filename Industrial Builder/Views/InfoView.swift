//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem on 10.05.2024.
//

import SwiftUI
import IndustrialKit

struct InfoView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var gallery: [Image] = []
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            TextEditor(text: $base_stc.package_info.description)
                .textEditorStyle(.plain)
                .font(.title3)
                .padding()
                .frame(maxHeight: .infinity)
                .onChange(of: base_stc.package_info.description)
            { _, new_value in
                document.package_info.description = new_value
                document_handler.document_update_info()
            }
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InfoGalleryView: View
{
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @Binding var document: STCDocument
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    
    @State private var update_toggle = false
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                
            }
            .animation(.easeInOut, value: document.package_info.gallery)
        }
    }
}


#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
