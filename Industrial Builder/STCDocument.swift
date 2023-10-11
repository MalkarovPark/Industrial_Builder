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
    @Published var package = STCPackage()
    @Published var images = [UIImage]()
    
    init()
    {
        
    }
    
    func document_view(_ info: STCPackage, images: [UIImage])
    {
        self.package = info
        self.images = images
    }
}

#if os(macOS)
typealias UIImage = NSImage

extension UIImage
{
    func pngData() -> Data?
    {
        if let tiffRepresentation = self.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
        {
            return bitmapImage.representation(using: .png, properties: [:])
        }

        return nil
    }
}
#endif

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
    var images = [UIImage]()
    
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
            case "package.info":
                package_process()
            case "images":
                images_process()
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
            
            func images_process()
            {
                if let file_wrappers = wrapper.fileWrappers
                {
                    for (_, file_wrapper) in file_wrappers
                    {
                        if let filename = file_wrapper.filename, filename.hasSuffix(".png")
                        {
                            images.append(UIImage(data: file_wrapper.regularFileContents ?? Data()) ?? UIImage())
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Export functions
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        do
        {
            let data = try make_document_data()
            let json_file_wrapper = FileWrapper(regularFileWithContents: data)
            let filename = "package.info"
            json_file_wrapper.filename = filename
            
            //Store images to this imagesFileWrapper
            var images_file_wrapper = FileWrapper(directoryWithFileWrappers: [String : FileWrapper]())
            images_file_wrapper = try prepare_image_file_wrapper(from: images)
            
            let file_wrapper = FileWrapper(directoryWithFileWrappers: [
                filename: json_file_wrapper,
                "images": images_file_wrapper
            ])
            
            return file_wrapper
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
    
    func prepare_image_file_wrapper(from images: [UIImage]) throws -> FileWrapper
    {
        var fileWrappers = [String: FileWrapper]()
        var index = 0
        //print("🔮 \(images.count)")
        for image in images
        {
            guard let data = image.pngData() else
            {
                break
            }
            
            let name = "GalleryImage\(index + 1).png"
            let fileWrapper = FileWrapper(regularFileWithContents: data)
            fileWrapper.filename = name
            fileWrapper.preferredFilename = name
            
            fileWrappers[name] = fileWrapper
            index += 1
        }
        
        let directoryFileWrapper = FileWrapper(directoryWithFileWrappers: fileWrappers)
        return directoryFileWrapper
    }
}
