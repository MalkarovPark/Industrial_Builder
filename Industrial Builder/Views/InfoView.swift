//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem on 10.05.2024.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct InfoView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 24)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 320, maximum: .infinity), spacing: 24)]
    #endif
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            LazyVGrid(columns: columns, spacing: 24)
            {
                DescriptionTile(stc: stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 224)
                
                ModulesTile(stc: stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 224)
                
                ExportTile(stc: stc)
                    .frame(height: 224)
                
                AppDevTile(stc: stc)
                    .frame(height: 224)
            }
            .padding(20)
        }
    }
}

struct IconView<Content: View>: View
{
    let content: () -> Content
    
    var body: some View
    {
        ZStack
        {
            content()
                .scaledToFit()
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
