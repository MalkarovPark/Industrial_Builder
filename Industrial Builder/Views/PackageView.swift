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
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            /*Text("Information")
                .font(.title)
                .padding([.horizontal, .top])*/
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

struct InfoView: View
{
    @Binding var document: STCDocument
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @State private var gallery: [Image] = []
    
    @State private var load_panel_presented = false
    
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
                    VStack(spacing: 0)
                    {
                        ForEach(0..<document.package_info.gallery.count, id: \.self)
                        { index in
                            SimpleImageCard(image: document.package_info.gallery[index]) //(images: $document.package_info.gallery, image: document.package_info.gallery[index])
                            { is_presented in
                                ImageView(image: document.package_info.gallery[index])
                                    .frame(maxWidth: 320)
                            }
                        }
                    }
                }
                .frame(width: 192)
                .overlay(alignment: .bottomLeading)
                {
                    Button(action: {
                        document.package_info.clear_gallery()
                    })
                    {
                        Image(systemName: "eraser")
                            .frame(maxHeight: 24)
                    }
                    .buttonBorderShape(.roundedRectangle)
                    #if os(iOS)
                    .buttonStyle(.borderedProminent)
                    #endif
                    .controlSize(.extraLarge)
                    .padding()
                }
                .overlay(alignment: .bottomTrailing)
                {
                    Button(action: { load_panel_presented.toggle() })
                    {
                        Image(systemName: "square.and.arrow.down")
                            .frame(maxHeight: 24)
                    }
                    .buttonBorderShape(.roundedRectangle)
                    #if os(iOS)
                    .buttonStyle(.borderedProminent)
                    #endif
                    .controlSize(.extraLarge)
                    .padding()
                    .fileImporter(isPresented: $load_panel_presented,
                                          allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: import_images)
                }
            }
        }
        .modifier(ListBorderer())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    func import_images(_ res: Result<[URL], Error>)
    {
        document.package_info.clear_gallery()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            do
            {
                let urls = try res.get()
                
                for url in urls
                {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData)
                    {
                        document.package_info.gallery.append(image)
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            }
            catch
            {
                print(error.localizedDescription)
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

#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(width: 320, height: 240)
}
