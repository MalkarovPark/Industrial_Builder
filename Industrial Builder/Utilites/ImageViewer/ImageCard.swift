//
//  ImageCard.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

import IndustrialKit

struct ImageCard<Content: View>: View
{
    let image_item: ImageItem
    
    let content: (_ is_presented: Binding<Bool>) -> Content
    
    @State private var is_presented = false
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_renaming: Bool = false
    @State private var new_name: String = String()
    @FocusState private var is_focused: Bool
    
    @State private var hovered = false
    
    var body: some View
    {
        Button
        {
            is_renaming = false
            is_presented.toggle()
        }
        label:
        {
            ZStack
            {
                ImageItemView(image: image_item.image)
                    .overlay(alignment: .bottomLeading)
                    {
                        HStack
                        {
                            if !is_renaming
                            {
                                VStack(alignment: .leading)
                                {
                                    Text(image_name)
                                        .font(.headline)
                                        .padding(.vertical, 8)
                                        .padding(.leading, 4)
                                }
                                .padding(.horizontal, 8)
                                .padding(.trailing, 4)
                            }
                            else
                            {
                                VStack(alignment: .leading)
                                {
                                    HStack
                                    {
                                        #if os(macOS)
                                        TextField("Name", text: $new_name)
                                            .textFieldStyle(.roundedBorder)
                                            .focused($is_focused)
                                            .labelsHidden()
                                            .padding()
                                            .onSubmit
                                            {
                                                on_rename(new_name)
                                                is_renaming = false
                                            }
                                            .onExitCommand
                                            {
                                                is_renaming = false
                                            }
                                        #else
                                        TextField(
                                            "Name",
                                            text: $new_name, onCommit:
                                                {
                                                    on_rename(new_name)
                                                    is_renaming = false
                                                }
                                        )
                                        .textFieldStyle(.roundedBorder)
                                        .focused($is_focused)
                                        .labelsHidden()
                                        .padding()
                                        #endif
                                    }
                                }
                            }
                        }
                        #if !os(visionOS)
                        .background(.bar)
                        #else
                        .background(.thinMaterial)
                        #endif
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(8)
                        .onChange(of: is_renaming)
                        { _, new_value in
                            is_focused = new_value
                        }
                        .onChange(of: is_focused)
                        { _, new_value in
                            if !new_value
                            {
                                is_renaming = false
                            }
                        }
                        /*Text(image_item.name)
                            .padding(8)
                            .background
                            {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .padding(8)*/
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .offset(y: hovered && !is_renaming ? -2 : 0)
            .onChange(of: is_renaming)
            { _, new_value in
                is_focused = new_value
                new_name = image_name
            }
            .onChange(of: is_focused)
            { _, new_value in
                if !new_value
                {
                    is_renaming = false
                }
            }
        }
        .buttonStyle(.plain)
        .background
        {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .blur(radius: 16)
                .opacity(0.2)
        }
        .frame(height: 192)
        .onHover
        { hovered in
            withAnimation(.easeInOut(duration: 0.2))
            {
                self.hovered = hovered
            }
        }
        .sheet(isPresented: $is_presented, content: { content($is_presented).presentationSizing(.fitted) })
        .contextMenu
        {
            RenameButton()
                .renameAction
            {
                withAnimation
                {
                    is_renaming = true
                }
            }
            
            Button(role: .destructive, action: delete_image)
            {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var image_name: String
    {
        return URL(fileURLWithPath: image_item.name).deletingPathExtension().lastPathComponent
    }
    
    private var image_extension: String
    {
        return URL(fileURLWithPath: image_item.name).pathExtension
    }
    
    private func on_rename(_ new_name: String)
    {
        if !new_name.isEmpty
        {
            let ext = image_extension.isEmpty ? "png" : image_extension
            
            let unique_name = unique_name(
                for: new_name,
                in: image_names(with: ext).filter { $0 != image_name }
            )
            
            if image_item.name != "\(unique_name).\(ext)"
            {
                image_item.name = "\(unique_name).\(ext)"
                document_handler.document_update_images()
            }
        }
        
        is_renaming = false
        
        func image_names(with ext: String) -> [String]
        {
            let clean_ext = ext.trimmingCharacters(in: CharacterSet(charactersIn: ".")).lowercased()
            
            return base_stc.image_items.compactMap { item in
                let url = URL(fileURLWithPath: item.name)
                
                return url.pathExtension.lowercased() == clean_ext
                ? url.deletingPathExtension().lastPathComponent
                : nil
            }
        }
    }
    
    private func delete_image()
    {
        base_stc.image_items.removeAll { $0 == image_item }
        document_handler.document_update_images()
    }
}

private struct ImageItemView: View
{
    let image: UIImage
    
    public init(image: UIImage)
    {
        self.image = image
    }
    
    var body: some View
    {
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .background(.white)
        #else
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .background(.white)
        #endif
    }
}

#Preview
{
    ImageCard(image_item: ImageItem(name: "Image", image: UIImage()))
    { is_presented in
        EmptyView()
    }
    .padding()
}
