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
    static let stc_document = UTType(exportedAs: "celadon.IndustrialBuilder.stc")
}

public class StandardTemplateConstruct: ObservableObject
{
    @Published var package: STCPackage
    
    init()
    {
        self.package = STCPackage()
    }
    
    func document_view(_ info: STCPackage)
    {
        self.package = info
    }
}

struct STCPackage: Codable
{
    var id: UUID
    var title: String
    var description: String
    
    var image_urls: [URL]
    
    init(id: UUID = .init(), title: String = .init(), description: String = .init(), image_urls: [URL] = .init())
    {
        self.id = id
        self.title = title
        self.description = description
        
        self.image_urls = image_urls
    }
}

struct STCDocument: FileDocument
{
    var package = STCPackage()
    
    static var readableContentTypes = [UTType.stc_document]
    
    init()
    {
        self.package = STCPackage()
    }
    
    //MARK: Import functions
    init(configuration: ReadConfiguration) throws
    {
        let wrappers = configuration.file.fileWrappers?.values
        for wrapper in wrappers!
        {
            file_process(wrapper: wrapper)
        }
        
        func file_process(wrapper: FileWrapper)
        {
            switch wrapper.filename
            {
            case "package.json":
                package_process()
            default:
                break
            }
            
            func package_process()
            {
                guard let data = wrapper.regularFileContents
                else
                {
                    return
                }
                
                package = try! JSONDecoder().decode(STCPackage.self, from: data)
            }
        }
    }
    
    //MARK: Export functions
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        do
        {
            let data = try make_document_data()
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            let filename = "package.json"
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
    
    private func make_document_data() throws -> Data
    {
        let encoder = JSONEncoder()
        
        do
        {
            let data = try encoder.encode(package)
            return data
        }
        catch
        {
            throw error
        }
    }
}
