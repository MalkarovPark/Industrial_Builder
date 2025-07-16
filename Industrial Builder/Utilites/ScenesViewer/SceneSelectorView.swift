//
//  ModelSelectorView.swift
//  Industrial Builder
//
//  Created by Artem on 04.11.2023.
//

import SwiftUI
import SceneKit
//import IndustrialKit
import IndustrialKitUI

struct SceneSelectorView: View
{
    @Binding var is_presented: Bool
    @Binding var scenes: [SCNScene]
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 88, maximum: 88), spacing: 0)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 132, maximum: 132), spacing: 0)]
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView
            {
                LazyVGrid(columns: columns, spacing: 8)
                {
                    NoElementItemView()
                        .onTapGesture
                        {
                            is_presented = false
                        }
                    
                    ForEach(scenes.indices, id: \.self)
                    { index in
                        ElementItemView(node: scenes[index].rootNode, action: { print(index); is_presented = false })
                            .id(index)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    }
                }
                .padding()
            }
        }
        .frame(width: 296, height: 296)
    }
}

struct ElementItemView: View
{
    var node: SCNNode
    var action: () -> ()
    
    var body: some View
    {
        ZStack
        {
            Button(action: action)
            {
                ObjectSceneView(node: node)
                    .disabled(true)
            }
            .buttonStyle(.borderless)
        }
        #if os(macOS)
        .frame(width: 80, height: 80)
        #else
        .frame(width: 120, height: 120)
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
        .shadow(radius: 1)
    }
}

struct NoElementItemView: View
{
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .foregroundStyle(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
                .shadow(radius: 1)
                .padding(4)
            Image(systemName: "nosign")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
        }
        #if os(macOS)
        .frame(width: 80, height: 80)
        #else
        .frame(width: 120, height: 120)
        #endif
    }
}

#Preview
{
    SceneSelectorView(is_presented: .constant(true), scenes: .constant([SCNScene]()))
}
