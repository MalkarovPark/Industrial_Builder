//
//  BuildView.swift
//  Industrial Builder
//
//  Created by Artem on 13.10.2023.
//

import SwiftUI

struct BuildView: View
{
    @State private var targets_palette_view_presented = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            BuildItemView(title: "RCWorkspace", subtitle: "None", image: Image(systemName: "swift"))
            {
                print("App")
            }
            .padding([.horizontal, .top])
            
            BuildItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
            {
                print("Packages")
            }
            .padding([.horizontal, .top])
            
            Spacer()
        }
    }
}

struct BuildItemView: View
{
    let title: String
    let subtitle: String
    let image: Image
    let on_tap: (() -> ())
    
    var body: some View
    {
        GroupBox
        {
            HStack
            {
                ZStack
                {
                    Rectangle()
                        .foregroundStyle(Color.accentColor)
                    image
                        .scaledToFit()
                        .foregroundStyle(.white)
                }
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(radius: 2)
                
                VStack(alignment: .leading)
                {
                    Text(title)
                    
                    Text(subtitle)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.trailing, 8)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
        }
        .onTapGesture
        {
            on_tap()
        }
    }
}

#Preview
{
    BuildView()
}

#Preview
{
    BuildItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
    {
        print("Packages")
    }
}
