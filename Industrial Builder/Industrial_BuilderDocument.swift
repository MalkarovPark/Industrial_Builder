//
//  Industrial_BuilderDocument.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 07.10.2023.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

extension UTType
{
    static let stcdocument = UTType(exportedAs: "celadon.IndustrialBuilder.stc")
}

struct StandardTemplateConstruct: Codable
{
    var id: UUID
    var title: String
    var textContent: String
    var imageUrls: [URL]
    
    init(id: UUID = .init(), title: String = "New Document", textContent: String = .init(), imageUrls: [URL] = .init())
    {
        self.id = id
        self.title = title
        self.textContent = textContent
        self.imageUrls = imageUrls
    }
}

struct Industrial_BuilderDocument: FileDocument
{
    var document: StandardTemplateConstruct
    
    static var readableContentTypes = [UTType.stcdocument]
    
    init(document: StandardTemplateConstruct = StandardTemplateConstruct())
    {
        self.document = document
    }
    
    init(configuration: ReadConfiguration) throws
    {
        self.init()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        do
        {
            let data = try getDocumentData()
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            let filename = "document.json"
            jsonFileWrapper.filename = filename
            
            //TODO: store images to this imagesFileWrapper
            let imagesFileWrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            
            let fileWrapper = FileWrapper(directoryWithFileWrappers: [
                filename: jsonFileWrapper,
                "images": imagesFileWrapper
            ])
                
            return fileWrapper
        }
        catch
        {
            throw error
        }
    }
    
    private func getDocumentData() throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(document)
            return data
        }
        catch
        {
            throw error
        }
    }
}
