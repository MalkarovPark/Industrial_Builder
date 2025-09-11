//
//  PackageView.swift
//  Industrial Builder
//
//  Created by Artem on 09.10.2023.
//

import SwiftUI
import PhotosUI
import IndustrialKit

struct PackageView: View
{
    @Binding var document: STCDocument
    
    @State private var pkg_tab_selection = 0
    @State private var build_view_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            InfoView(document: $document)
            #if !os(visionOS)
                .background(.white)
            #endif
                // .ignoresSafeArea(.container, edges: .bottom)
        }
        .sheet(isPresented: $build_view_presented)
        {
            ProcessView(document: $document, is_presented: $build_view_presented)
            #if os(macOS)// || os(visionOS)
                .presentationSizing(.fitted)
            #endif
            #if os(macOS)
                .frame(minWidth: 320, maxWidth: 600, minHeight: 400, maxHeight: 640)
            #endif
        }
        //.presentationSizing(.fitted)
        .toolbar
        {
            Button(action: { build_view_presented = true })
            {
                Image(systemName: "square.and.arrow.up.on.square")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
        }
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        #endif
    }
}

#Preview
{
    PackageView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
