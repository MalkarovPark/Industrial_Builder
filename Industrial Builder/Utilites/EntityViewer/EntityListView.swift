//
//  SceneListView.swift
//  Industrial Builder
//
//  Created by Artem on 04.11.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import RealityKit

import IndustrialKit
import IndustrialKitUI

// MARK: - EntityListView
struct EntityListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if !base_stc.entity_items.isEmpty
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.entity_items)
                        { item in
                            SceneCard(entity_item: item)
                            { is_presented in
                                EntityFileView(entity: item.entity)
                                    .frame(minWidth: 320, idealWidth: 640, maxWidth: 800,
                                           minHeight: 240, idealHeight: 480, maxHeight: 600)
                                    .modifier(SheetCaption(is_presented: is_presented, label: item.name, plain: false))
                            }
                        }
                    }
                    .padding(20)
                }
                .animation(.spring(), value: base_stc.entity_items)
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Entities", systemImage: "cube")
                }
            }
        }
        .overlay
        {
            if is_targeted
            {
                VStack
                { Text("Drop scenes here").foregroundColor(.secondary).padding() }
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $is_targeted)
        { providers in
            
            Task
            {
                let urls = await extract_urls(from: providers)
                await load_scenes(from: urls)
            }
            
            return true
        }
        .toolbar
        {
            Button(action: { load_panel_presented = true })
            {
                Image(systemName: "square.and.arrow.down")
            }
            .fileImporter(isPresented: $load_panel_presented,
                          allowedContentTypes: [.usdz, .realityFile],
                          allowsMultipleSelection: true)
            { result in
                
                switch result
                {
                case .success(let urls):
                    
                    Task
                    {
                        await load_scenes(from: urls)
                    }
                    
                case .failure(let error):
                    print("Import error:", error.localizedDescription)
                }
            }
        }
    }
    
    private func extract_urls(from providers: [NSItemProvider]) async -> [URL]
    {
        var result = [URL]()
        
        for provider in providers
        {
            guard provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
            else { continue }
            
            do
            {
                let data = try await load_file_url_data(from: provider)
                
                if let url = URL(dataRepresentation: data, relativeTo: nil)
                {
                    result.append(url)
                }
            }
            catch
            {
                print("Drop load error: \(error)")
            }
        }
        
        return result
    }
    
    private func load_file_url_data(from provider: NSItemProvider) async throws -> Data
    {
        try await withCheckedThrowingContinuation
        { continuation in
            
            provider.loadDataRepresentation(
                forTypeIdentifier: UTType.fileURL.identifier
            )
            { data, error in
                
                if let error = error
                {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data
                else
                {
                    continuation.resume(
                        throwing: NSError(
                            domain: "DropError",
                            code: -1
                        )
                    )
                    return
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    private func load_scenes(from urls: [URL]) async
    {
        for url in urls
        {
            await handle_file_sequential(url: url)
        }
        
        await MainActor.run
        {
            document_handler.document_update_scenes()
        }
    }
    
    private func handle_file_sequential(url: URL) async
    {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do
        {
            let entity = try await Entity(contentsOf: url)
            let item = EntityItem(
                name: url.lastPathComponent,
                entity: entity,
                source_url: url
            )
            
            await MainActor.run
            {
                base_stc.entity_items.append(item)
                document_handler.document_update_scenes()
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
}

#Preview
{
    EntityListView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
}
