//
//  ScenesListView.swift
//  Industrial Builder
//
//  Created by Artem on 04.11.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import RealityKit

import IndustrialKit
import IndustrialKitUI

// MARK: - Scene item wrapper
class EntityItem: Identifiable, Equatable, ObservableObject
{
    public let id: UUID = UUID()
    
    static func == (lhs: EntityItem, rhs: EntityItem) -> Bool
    {
        lhs.id == rhs.id
    }
    
    public var name: String
    public var entity: Entity
    
    public var source_url: URL?
    
    public init(
        name: String,
        entity: Entity,
        source_url: URL? = nil
    )
    {
        self.entity = entity
        self.name = name
        self.source_url = source_url
    }
}

// MARK: - ScenesListView
struct ScenesListView: View
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
            if !base_stc.entities.isEmpty
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.entities)
                        { item in
                            SceneCard(entity_item: item)
                            { is_presented in
                                SceneFileView(entity: item.entity)
                                    .frame(minWidth: 320, idealWidth: 640, maxWidth: 800,
                                           minHeight: 240, idealHeight: 480, maxHeight: 600)
                                    .modifier(SheetCaption(is_presented: is_presented, label: item.name, plain: false))
                            }
                        }
                    }
                    .padding(20)
                }
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
                
                for url in urls
                {
                    await handle_file_sequential(url: url)
                }
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
                          allowsMultipleSelection: true,
                          onCompletion: import_scenes)
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
                base_stc.entities.append(item)
                document_handler.document_update_scenes()
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Handle single file
    private func handle_file(url: URL)
    {
        Task
        {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do
            {
                let entity = try await Entity(contentsOf: url)
                let item = EntityItem(name: url.lastPathComponent, entity: entity, source_url: url)
                
                await MainActor.run
                {
                    base_stc.entities.append(item)
                    document_handler.document_update_scenes()
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Handle fileImporter result
    private func import_scenes(_ res: Result<[URL], Error>)
    {
        do
        {
            let urls = try res.get()
            for url in urls { handle_file(url: url) }
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
}

#Preview
{
    ScenesListView()
        .environmentObject(StandardTemplateConstruct())
        .environmentObject(DocumentUpdateHandler())
}
