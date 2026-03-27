//
//  FilesPattern.swift
//  Industrial Builder
//
//  Created by Artem on 27.03.2026.
//

import Foundation

// MARK: - Template
public class FilesPattern: Hashable, Identifiable
{
    public static func == (lhs: FilesPattern, rhs: FilesPattern) -> Bool
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
    
    public var children: [FilesPattern]?
    
    public var write_func: ((String, URL) -> ())?
    
    public init(
        name: String,
        data: String? = nil,
        
        children: [FilesPattern]? = nil
    )
    {
        self.name = name
        self.data = data
        
        self.children = children
        self.write_func = nil
    }
    
    public init(
        name: String,
        
        write_func: @escaping (String, URL) -> ()
    )
    {
        self.name = name
        
        self.write_func = write_func
    }
}

// MARK: - Functions
public func make_files(by pattern: FilesPattern, to folder_url: URL)
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
            print(error.localizedDescription)
        }
    }
}

// MARK: Recursive builder
private func create_node(_ node: FilesPattern, at url: URL) throws
{
    let node_url = url.appendingPathComponent(node.name)
    
    // Folder
    if node.children != nil || (node.children == nil && node.data == nil && node.write_func == nil)
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
    if let write_func = node.write_func
    {
        if FileManager.default.fileExists(atPath: node_url.path)
        {
            try FileManager.default.removeItem(at: node_url)
        }
        
        write_func(node.data ?? "", node_url)
        return
    }
}

// Init Samples
/*let file = FilesPattern(
    name: "File",
    data: """
Simple Text Data
"""
)

let file_with_custom_write_func = FilesPattern(
    name: "Custom",
    write_func:
        {
            print("Writing: \($0) to: \($1.path)")
        }
)

let empty_folder = FilesPattern(
    name: "Empty Folder"
)

let folder = FilesPattern(
    name: "Folder",
    children: [
        file,
        file_with_custom_write_func,
        empty_folder
    ]
)*/
