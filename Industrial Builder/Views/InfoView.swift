//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 10.05.2024.
//

import SwiftUI
import IndustrialKit

struct InfoView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var gallery: [Image] = []
    @State private var load_panel_presented = false
    
    var body: some View
    {
        ZStack(alignment: .trailing)
        {
            HStack(spacing: 0)
            {
                ZStack
                {
                    Rectangle()
                        .foregroundColor(.clear)
                }
                .frame(maxWidth: .infinity)
                
                //Divider()
                
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
                .overlay(alignment: .bottom)
                {
                    VStack(spacing: 0)
                    {
                        Divider()
                        HStack
                        {
                            Button(action: {
                                document.package_info.clear_gallery()
                            })
                            {
                                Image(systemName: "eraser")
                                #if os(iOS)
                                    .frame(width: 24, height: 24)
                                #else
                                    .frame(maxHeight: 24)
                                #endif
                            }
                            .controlSize(.extraLarge)
                            .buttonStyle(.plain)
                            .padding()
                            
                            Spacer()
                            
                            Button(action: { load_panel_presented.toggle() })
                            {
                                Image(systemName: "square.and.arrow.down")
                                #if os(iOS)
                                    .frame(width: 24, height: 24)
                                #else
                                    .frame(maxHeight: 24)
                                #endif
                            }
                            .controlSize(.extraLarge)
                            .buttonStyle(.plain)
                            .padding()
                            .fileImporter(isPresented: $load_panel_presented,
                                                  allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: import_images)
                        }
                        .frame(maxWidth: .infinity)
                        .background(.white)
                    }
                }
            }
            
            HStack(spacing: 0)
            {
                ZStack
                {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .shadow(radius: 4)
                    
                    VStack(spacing: 0)
                    {
                        TextField("Name", text: $base_stc.package_info.title)
                            .textFieldStyle(.plain)
                            .font(.title2)
                            .padding()
                            .onChange(of: base_stc.package_info.title)
                        { _, new_value in
                            document.package_info.title = new_value
                        }
                        
                        Divider()
                        
                        TextEditor(text: $base_stc.package_info.description)
                            .textEditorStyle(.plain)
                            .font(.title3)
                            .padding()
                            .frame(maxHeight: .infinity)
                            .onChange(of: base_stc.package_info.description)
                        { _, new_value in
                            document.package_info.description = new_value
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                //Divider()
                
                VStack
                {
                    
                }
                .frame(width: 192)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
