//
//  PackageView.swift
//  Industrial Builder
//
//  Created by Artem on 09.10.2023.
//

import SwiftUI

struct PackageView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                Text("Information")
                    .font(.title2)
                    .padding()
                
                HStack(spacing: 8)
                {
                    Text("Title")
                    TextField("Title", text: $base_stc.package_info.title)
                        .textFieldStyle(.roundedBorder)
                }
                .padding([.bottom, .horizontal])
                .onChange(of: base_stc.package_info.title)
                { oldValue, newValue in
                    document.package_info.title = newValue
                }
                
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Description")
                    TextEditor(text: $base_stc.package_info.description)
                        .frame(minHeight: 192)
                        .modifier(ListBorderer())
                }
                .padding([.bottom, .horizontal])
                .onChange(of: base_stc.package_info.description)
                { oldValue, newValue in
                    document.package_info.description = newValue
                }
                
                Text("Gallery")
                    .font(.title2)
                    .padding([.bottom, .horizontal])
                
                GalleryView()
                    .padding([.bottom, .horizontal])
            }
        }
        .modifier(WindowFramer())
    }
}

#Preview
{
    PackageView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
