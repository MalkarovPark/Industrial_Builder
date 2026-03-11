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
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            InfoView(document: $document)
        }
        //.presentationSizing(.fitted)
        /*.toolbar
        {
            Button(action: { build_view_presented = true })
            {
                Image(systemName: "square.and.arrow.up.on.square")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
        }*/
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
