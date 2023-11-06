//
//  ModelSelectorView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 04.11.2023.
//

import SwiftUI
import SceneKit

struct ModelSelectorView: View
{
    @Binding var is_presented: Bool
    @Binding var nodes: [SCNNode]
    
    //private let numbers = (0...16).map { $0 }
    
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
                            print("No")
                            is_presented = false
                        }
                    
                    ForEach(nodes.indices, id: \.self)
                    { index in
                        ElementItemView(node: nodes[index], action: { print(index); is_presented = false })
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
                ElementSceneView(node: node)
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
    ModelSelectorView(is_presented: .constant(true), nodes: .constant([SCNNode]()))
}
