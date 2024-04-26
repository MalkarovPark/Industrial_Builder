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
            ZStack
            {
                HStack(alignment: .center)
                {
                    Text(label)
                        .padding(0)
                }
                
                HStack(spacing: 0)
                {
                    Button(action: { is_presented = false })
                    {
                        Image(systemName: "xmark")
                    }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(.borderless)
                    .controlSize(.extraLarge)
                    .padding()
                    
                    Spacer()
                }
            }
            
            Divider()
            
            Spacer(minLength: 0)
            
            #if os(macOS)
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #else
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #endif
            
            Spacer(minLength: 0)
        }
        #if os(macOS)
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
