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
                .modifier(WindowFramer())
        }
        .modifier(WindowFramer())
        .sheet(isPresented: $build_view_presented)
        {
            BuildView(document: $document)
                .modifier(SheetCaption(is_presented: $build_view_presented, label: "Build"))
                .fitted()
            #if os(macOS)
                .frame(minWidth: 600, maxWidth: 600, minHeight: 480, maxHeight: 640)
            #endif
        }
        .toolbar
        {
            Button(action: { build_view_presented = true })
            {
                Image(systemName: "square.and.arrow.up.on.square")
            }
        }
    }
}

#Preview
{
    PackageView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
