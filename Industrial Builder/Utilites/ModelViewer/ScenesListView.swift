//
//  ScenesListView.swift
//  Industrial Builder
//
//  Created by Artem on 04.11.2023.
//

import SwiftUI
import IndustrialKit
import SceneKit

struct ScenesListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    
    @State private var is_targeted = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.scenes.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.scenes.indices, id: \.self)
                        { index in
                            ModelCard(scene: $base_stc.scenes[index], name: "Scene\(index + 1)")
                            { is_presented in
                                SceneView(node: root_node_binding(for: base_stc.scenes[index]))
                                    .modifier(WindowFramer())
                                    .modifier(ViewCloseButton(is_presented: is_presented))
                            }
                        }
                    }
                    .padding(20)
                }
                .modifier(DoubleModifier(update_toggle: $app_state.update_scenes_document_notify))
            }
            else
            {
                NoView(label: "No Scenes")
            }
        }
        .overlay
        {
            if is_targeted
            {
                VStack
                {
                    Text("Drop scenes here")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .onDrop(of: [.sceneKitScene], isTargeted: $is_targeted)
        { providers in
            perform_drop(providers: providers)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(WindowFramer())
        .toolbar
        {
            ToolbarItem(placement: .automatic)
            {
                Button (action: { })
                {
                    Label("Add Model", systemImage: "plus")
                }
            }
        }
    }
    
    func root_node_binding(for scene: SCNScene) -> Binding<SCNNode>
    {
        Binding<SCNNode>(
            get: { scene.rootNode },
            set: { newNode in
                
            }
        )
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            if provider.hasItemConformingToTypeIdentifier("com.apple.scenekit.scene")
            {
                provider.loadInPlaceFileRepresentation(forTypeIdentifier: "com.apple.scenekit.scene")
                { (fileURL, isWritable, error) in
                    DispatchQueue.main.async
                    {
                        if let fileURL = fileURL
                        {
                            do
                            {
                                let scene = try SCNScene(url: fileURL, options: nil)
                                self.base_stc.scenes.append(scene)
                                
                                app_state.document_update_scenes()
                            }
                            catch
                            {
                                print(error.localizedDescription)
                            }
                        }
                        else if let error = error
                        {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        return true
    }
}

#Preview
{
    ScenesListView()
}
