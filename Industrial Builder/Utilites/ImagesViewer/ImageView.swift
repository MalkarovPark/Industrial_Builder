//
//  ImageView.swift
//  Industrial Builder
//
//  Created by Artiom on 29.03.2024.
//

import SwiftUI
import IndustrialKit

struct ImageView: View
{
    @Binding var is_presented: Bool
    
    let image: UIImage
    let label: String
    
    var body: some View
    {
        VStack(spacing: 0)
        {
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
        .modifier(SheetCaption(is_presented: $is_presented, label: label))
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
