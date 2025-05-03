//
//  PrepareForDevView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 26.04.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct PrepareForDevView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var template_view_presented = false
    
    @State private var store_project_panel_presented = false
    @State private var store_listing_panel_presented = false
    @State private var store_mbk_panel_presented = false
    
    @State private var passed_listing_text = String()
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            Picker(selection: $base_stc.prepare_for_dev_type, label: Text("Export type"))
            {
                ForEach(PrepareForDevType.allCases, id: \.self)
                { export_type in
                    Text(export_type.rawValue).tag(export_type)
                }
            }
            .labelsHidden()
            #if os(macOS)
            .pickerStyle(.radioGroup)
            #else
            .pickerStyle(.wheel)
            #endif
        }
        .fileExporter(
            isPresented: $store_project_panel_presented,
            document: RawFileDocument(data: Data()),
            contentType: .data,
            defaultFilename: "Project"
        )
        { result in
            switch result
            {
            case .success(let url):
                let file_name = url.lastPathComponent
                let folder_url = url.deletingLastPathComponent()
                
                base_stc.make_industrial_app_project(name: file_name, to: folder_url, remove_tmp_from: url)
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar
        {
            ToolbarItem(placement: .confirmationAction)
            {
                Button("Export")
                {
                    switch base_stc.prepare_for_dev_type
                    {
                    case .blank_project:
                        store_project_panel_presented = true
                    case .from_listing:
                        template_view_presented = true
                    case .mbk_only:
                        store_mbk_panel_presented = true
                    }
                }
                .fileExporter(
                    isPresented: $store_listing_panel_presented,
                    document: SwiftSourceDocument(content: passed_listing_text),
                    contentType: .swiftSource,
                    defaultFilename: "Listing"
                )
                { result in
                    switch result
                    {
                    case .success(let url):
                        let file_name = url.lastPathComponent
                        let folder_url = url.deletingLastPathComponent()
                        
                        base_stc.make_industrial_app_project(from: file_name, to: folder_url)
                        passed_listing_text = String()
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                .fileImporter(isPresented: $store_mbk_panel_presented,
                              allowedContentTypes: [.folder],
                              allowsMultipleSelection: false)
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            base_stc.store_mbk(to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                .sheet(isPresented: $template_view_presented)
                {
                    CodeBuilderView(is_presented: $template_view_presented, avaliable_templates_names: external_app_code_templates)
                    { output in
                        passed_listing_text = output
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            store_listing_panel_presented = true
                        }
                    }
                }
            }
        }
    }
}

struct SwiftSourceDocument: FileDocument
{
    static var readableContentTypes = [UTType.swiftSource]
    
    var text = ""
    
    init(configuration: ReadConfiguration) throws
    {
        if let data = configuration.file.regularFileContents
        {
            text = String(data: data, encoding: .utf8) ?? ""
        }
        else
        {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    init(content: String = "")
    {
        text = content
    }
}

struct RawFileDocument: FileDocument
{
    static var readableContentTypes: [UTType] { [.data] }
    var data: Data
    
    init(data: Data)
    {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws
    {
        self.data = configuration.file.regularFileContents ?? Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview
{
    PrepareForDevView()
}
