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
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    @State private var clear_message_presented = false
    
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
                            SceneCard(scene: $base_stc.scenes[index], name: "\(base_stc.scenes_files_names[index])")
                            { is_presented in
                                SceneView(node: root_node_binding(for: base_stc.scenes[index]))
                                    .frame(minWidth: 320, idealWidth: 640, maxWidth: 800, minHeight: 240, idealHeight: 480, maxHeight: 600)
                                    .modifier(ViewCloseButton(is_presented: is_presented))
                            }
                        }
                    }
                    .padding(20)
                }
                .modifier(DoubleModifier(update_toggle: $document_handler.update_scenes_document_notify))
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Scenes", systemImage: "cube")
                }
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
            Button(action: { clear_message_presented.toggle() })
            {
                Image(systemName: "eraser")
            }
            .confirmationDialog(Text("Remove all scenes?"), isPresented: $clear_message_presented)
            {
                Button("Remove", role: .destructive)
                {
                    base_stc.scenes.removeAll()
                    base_stc.scenes_files_names.removeAll()
                    document_handler.document_update_scenes()
                }
            }
            
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            .fileImporter(isPresented: $load_panel_presented,
                                  allowedContentTypes: [.sceneKitScene], allowsMultipleSelection: true, onCompletion: import_scenes)
        }
    }
    
    private func root_node_binding(for scene: SCNScene) -> Binding<SCNNode>
    {
        Binding<SCNNode>(
            get:
                {
                    scene.rootNode
                },
            set:
                { new_node in
                    
                }
        )
    }
    
    func perform_drop(providers: [NSItemProvider]) -> Bool
    {
        for provider in providers
        {
            if provider.hasItemConformingToTypeIdentifier("com.apple.scenekit.scene")
            {
                DispatchQueue.main.async
                {
                    provider.loadInPlaceFileRepresentation(forTypeIdentifier: "com.apple.scenekit.scene")
                    { (fileURL, isWritable, error) in
                        if let fileURL = fileURL
                        {
                            do
                            {
                                let scene = try SCNScene(url: fileURL, options: nil)
                                self.base_stc.scenes.append(scene)
                                self.base_stc.scenes_files_names.append(fileURL.lastPathComponent)
                                
                                document_handler.drop_document_update_scenes()
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
    
    func import_scenes(_ res: Result<[URL], Error>)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            do
            {
                let urls = try res.get()
                
                for url in urls
                {
                    guard url.startAccessingSecurityScopedResource() else { return }
                    if let scene = try? SCNScene(url: url, options: nil)
                    {
                        self.base_stc.scenes.append(scene)
                        self.base_stc.scenes_files_names.append(url.lastPathComponent)
                    }
                    url.stopAccessingSecurityScopedResource()
                    
                }
                document_handler.document_update_scenes()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview
{
    ScenesListView()
        .environmentObject(StandardTemplateConstruct())
}
