//
//  PackageView.swift
//  Industrial Builder
//
//  Created by Artem on 09.10.2023.
//

import SwiftUI
import PhotosUI

struct PackageView: View
{
    @Binding var document: STCDocument
    
    @State private var pkg_tab_selection = 0
    @State private var work_folder_selector_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            switch pkg_tab_selection
            {
            case 0:
                InfoView(document: $document)
                    .modifier(WindowFramer())
            default:
                BuildView()
            }
        }
        .toolbar
        {
            Picker("Package", selection: $pkg_tab_selection)
            {
                Text("Info").tag(0)
                Text("Build").tag(1)
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview
{
    PackageView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
