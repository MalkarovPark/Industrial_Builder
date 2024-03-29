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
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Text("Information")
                .font(.title)
                .padding([.horizontal, .top])
            
            InfoView(document: $document)
                .modifier(WindowFramer())
        }
    }
}

struct InfoView: View
{
    @Binding var document: STCDocument
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State var selected_items: [PhotosPickerItem] = []
    @State private var gallery: [Image] = []
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .foregroundStyle(.white)
            HStack(spacing: 0)
            {
                VStack(spacing: 0)
                {
                    TextField("Name", text: $base_stc.package_info.title)
                        .textFieldStyle(.plain)
                        .font(.title2)
                        .padding()
                        .onChange(of: base_stc.package_info.title)
                        { oldValue, newValue in
                            document.package_info.title = newValue
                        }
                    
                    Divider()
                    
                    TextEditor(text: $base_stc.package_info.description)
                        .textEditorStyle(.plain)
                        .font(.title3)
                        .padding()
                        .frame(maxHeight: .infinity)
                        .onChange(of: base_stc.package_info.description)
                        { oldValue, newValue in
                            document.package_info.description = newValue
                        }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                ScrollView(.vertical)
                {
                    LazyVStack(spacing: 0)
                    {
                        ForEach(0..<gallery.count, id: \.self)
                        { index in
                            gallery[index]
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(width: 192)
            }
        }
        .modifier(ListBorderer())
        .overlay(alignment: .bottomTrailing)
        {
            PhotosPicker(selection: $selected_items,
                matching: .images)
            {
                Image(systemName: "photo.badge.plus")
            }
            .controlSize(.extraLarge)
            .padding()
        }
        .onChange(of: selected_items)
        {
            Task
            {
                gallery.removeAll()
                
                for item in selected_items
                {
                    if let image = try? await item.loadTransferable(type: Image.self)
                    {
                        gallery.append(image)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview
{
    PackageView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(width: 320, height: 240)
}
