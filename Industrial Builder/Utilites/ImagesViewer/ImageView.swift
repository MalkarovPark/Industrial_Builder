//
//  ImageView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 29.03.2024.
//

import SwiftUI

struct ImageView: View
{
    @Binding var is_presented: Bool
    
    let image: UIImage
    let label: String
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            #if !os(macOS)
            HStack(spacing: 0)
            {
                Button(action: { is_presented = false })
                {
                    Image(systemName: "xmark")
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.extraLarge)
                .padding()
                
                Spacer()
                
                Text(label)
                    .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            #endif
            
            #if os(macOS)
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #endif
        }
        #if os(macOS)
        .toolbar
        {
            ToolbarItem(placement: .automatic)
            {
                Button(action: { is_presented = false })
                {
                    Image(systemName: "xmark")
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.extraLarge)
            }
            
            ToolbarItem(placement: .cancellationAction)
            {
                Text(label)
            }
        }
        .frame(minWidth: 320, maxWidth: 800, minHeight: 240, maxHeight: 600)
        #else
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
}

struct SimpleImageView: View
{
    let image: UIImage
    
    var body: some View
    {
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        #else
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        #endif
    }
}

#Preview
{
    ImageView(is_presented: .constant(true), image: UIImage(), label: "image.png")
}

#Preview
{
    SimpleImageView(image: UIImage())
}
