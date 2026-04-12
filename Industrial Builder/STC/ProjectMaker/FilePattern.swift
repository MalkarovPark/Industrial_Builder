//
//  FilesPattern.swift
//  Industrial Builder
//
//  Created by Artem on 27.03.2026.
//

import Foundation

// MARK: - Storage
public class FilePattern: Hashable, Identifiable
{
    public static func == (lhs: FilePattern, rhs: FilePattern) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
    
    public var id = UUID()
    
    public var name: String
    public var data: String?
    
    public var children: [FilePattern]?
    
    public var writing_func: ((URL) -> ())?
    
    public init(
        name: String,
        data: String? = nil,
        
        children: [FilePattern]? = nil
    )
    {
        self.name = name
        self.data = data
        
        self.children = children
        self.writing_func = nil
    }
    
    public init(
        writing_func: @escaping (URL) -> ()
    )
    {
        self.name = String()
        
        self.writing_func = writing_func
    }
}

// MARK: - Functions
public func make_files(by pattern: FilePattern, to folder_url: URL)
{
    DispatchQueue.global(qos: .background).async
    {
        guard folder_url.startAccessingSecurityScopedResource() else
        {
            return
        }
        
        defer
        {
            folder_url.stopAccessingSecurityScopedResource()
        }
        
        do
        {
            try create_node(pattern, at: folder_url)
        }
        catch
        {
            //print(error.localizedDescription)
        }
    }
}

// MARK: Recursive builder
private func create_node(_ node: FilePattern, at url: URL) throws
{
    let node_url = url.appendingPathComponent(node.name)
    
    // Folder
    if node.children != nil || (node.children == nil && node.data == nil && node.writing_func == nil)
    {
        if FileManager.default.fileExists(atPath: node_url.path)
        {
            try FileManager.default.removeItem(at: node_url)
        }
        
        try FileManager.default.createDirectory(
            at: node_url,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        if let children = node.children
        {
            for child in children
            {
                try create_node(child, at: node_url)
            }
        }
        
        return
    }
    
    // Normal file with data
    if let data = node.data
    {
        if FileManager.default.fileExists(atPath: node_url.path)
        {
            try FileManager.default.removeItem(at: node_url)
        }
        
        try data.write(
            to: node_url,
            atomically: true,
            encoding: .utf8
        )
        
        return
    }
    
    // Custom file writer
    if let writing_func = node.writing_func
    {
        writing_func(node_url)
        return
    }
}
