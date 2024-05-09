//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 10.05.2024.
//

import SwiftUI

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
                                SimpleImageView(image: document.package_info.gallery[index])
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
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
