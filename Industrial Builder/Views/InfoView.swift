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
                
                InfoGalleryView(document: $document)
            }
            
            HStack(spacing: 0)
            {
                ZStack
                {
                    Rectangle()
                    #if !os(visionOS)
                        .foregroundColor(.white)
                    #else
                        .foregroundStyle(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    #endif
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    #if !os(visionOS)
                        .shadow(radius: 4)
                    #endif
                    
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
                #if os(visionOS)
                .padding()
                #endif
                
                VStack
                {
                    
                }
                .frame(width: 192)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InfoGalleryView: View
{
    @Binding var document: STCDocument
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    
    @State private var update_toggle = false
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                ForEach(0..<document.package_info.gallery.count, id: \.self)
                { index in
                    SimpleImageCard(image: document.package_info.gallery[index])
                    { is_presented in
                        SimpleImageView(image: document.package_info.gallery[index])
                            .frame(maxWidth: 320)
                    }
                    .contextMenu
                    {
                        Button(role: .destructive)
                        {
                            delete_image(index: index)
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .transition(.opacity) // Добавляем переход для анимации исчезновения
                }
            }
            .animation(.easeInOut, value: document.package_info.gallery)
            .modifier(DoubleModifier(update_toggle: $update_toggle))
        }
        .frame(width: 192)
        .overlay(alignment: .bottom)
        {
            #if !os(visionOS)
            VStack(spacing: 0)
            {
                Divider()
                HStack
                {
                    Button(action: {
                        document.package_info.clear_gallery()
                    })
                    {
                        Image(systemName: "trash")
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
                .background(.ultraThinMaterial)
            }
            #else
            HStack
            {
                Button(action: {
                    document.package_info.clear_gallery()
                })
                {
                    Image(systemName: "trash")
                        .padding()
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                
                Button(action: { load_panel_presented.toggle() })
                {
                    Image(systemName: "square.and.arrow.down")
                        .padding()
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .fileImporter(isPresented: $load_panel_presented,
                              allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: import_images)
            }
            .controlSize(.large)
            .padding()
            .glassBackgroundEffect()
            .padding(.bottom)
            #endif
        }
        .overlay
        {
            if is_targeted
            {
                VStack
                {
                    Text("Drop images here")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .onDrop(of: [.image], isTargeted: $is_targeted)
        { providers in
            perform_drop(providers: providers)
        }
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            DispatchQueue.main.async
            {
                provider.loadItem(forTypeIdentifier: "public.image", options: nil)
                { (item, error) in
                    if let url = item as? URL
                    {
                        if let image_data = try? Data(contentsOf: url)
                        {
                            guard let image = UIImage(data: image_data)
                            else
                            {
                                return
                            }
                            document.package_info.gallery.append(image)
                        }
                    }
                }
            }
        }
        return true
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
    
    func delete_image(index: Int)
    {
        withAnimation
        {
            document.package_info.gallery.remove(at: index)
        }
        update_toggle.toggle()
    }
}


#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
