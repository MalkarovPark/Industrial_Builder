//
//  PackageView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 09.10.2023.
//

import SwiftUI

struct PackageView: View
{
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical)
            {
                Text("Information")
                    .font(.title2)
                    .padding()
                
                HStack(spacing: 8)
                {
                    Text("Name")
                    TextField("Name", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                }
                .padding([.bottom, .horizontal])
                
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Description")
                    TextEditor(text: .constant(""))
                        .frame(minHeight: 192)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .shadow(radius: 1)
                }
                .padding([.bottom, .horizontal])
                
                //Divider()
                
                Text("Gallery")
                    .font(.title2)
                    .padding([.bottom, .horizontal])
                
                GalleryView()
                    .padding([.bottom, .horizontal])
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #else
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600) //Window sizes for macOS
        #endif
    }
}

#Preview
{
    PackageView()
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
}
