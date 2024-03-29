//
//  ImageView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 29.03.2024.
//

import SwiftUI

struct ImageView: View
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

#Preview {
    ImageView(image: UIImage())
}
