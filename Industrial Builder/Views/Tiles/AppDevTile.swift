//
//  AppDevTile.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI
import UniformTypeIdentifiers

import IndustrialKitUI

struct AppDevTile: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    @State private var code_template_view_presented = false
    @State private var store_listing_panel_presented = false
    @State private var passed_listing_text = String()
    
    @State private var project_export_panel_presented = false
    @State private var project_export_option: ProjectExportOption = .swift_playground
    
    @State private var hovered = false
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        GlassTile(color: Color(hex: "6F7AB9"))
        {
            HStack(spacing: 0)
            {
                ZStack
                {
                    Rectangle()
                        .fill(Color(hex: "6F7AB9"))
                    
                    Button
                    {
                        code_template_view_presented = true
                    }
                    label:
                    {
                        IconView
                        {
                            ZStack
                            {
                                Rectangle()
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: Color(hex: "2E2E2E"), location: 0.0),
                                                Gradient.Stop(color: Color(hex: "262626"), location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaledToFill()
                                
                                Image(systemName: "terminal")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30))
                            }
                        }
                    }
                    .buttonStyle(.plain)
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
                            
                            stc.make_industrial_app_project(from: file_name, to: folder_url)
                            passed_listing_text = String()
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                    .sheet(isPresented: $code_template_view_presented)
                    {
                        CodeSelectorView(
                            is_presented: $code_template_view_presented,
                            avaliable_template_names: external_app_code_templates
                        )
                        { output in
                            passed_listing_text = output
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                            {
                                store_listing_panel_presented = true
                            }
                        }
                    }
                }
                .overlay(alignment: .bottom)
                {
                    Text("Terinal App")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.bottom, 12)
                }
                
                ZStack
                {
                    Rectangle()
                        .fill(Color(hex: "3671D9"))
                    
                    Menu
                    {
                        ForEach(ProjectExportOption.allCases, id: \.self)
                        { export_type in
                            Button(export_type.rawValue)
                            {
                                project_export_option = export_type
                                project_export_panel_presented = true
                            }
                        }
                    }
                    label:
                    {
                        IconView
                        {
                            ZStack
                            {
                                Rectangle()
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: .white, location: 0.0),
                                                Gradient.Stop(color: Color(hex: "F1F2FA"), location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaledToFill()
                                
                                Image(systemName: "app.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: Color(hex: "0FC1FB"), location: 0.0),
                                                Gradient.Stop(color: Color(hex: "1F74FF"), location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .font(.system(size: 50))
                                
                                Image(systemName: "hammer.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                Gradient.Stop(color: Color(hex: "70727E"), location: 0.0),
                                                Gradient.Stop(color: Color(hex: "16181B"), location: 1.0)
                                            ]),
                                            startPoint: .topTrailing,
                                            endPoint: .bottomLeading
                                        )
                                    )
                                    .font(.system(size: 25))
                            }
                            .overlay(alignment: .bottomTrailing)
                            {
                                if hovered
                                {
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 12))
                                        .padding(8)
                                }
                            }
                        }
                        .onHover
                        { hovered in
                            withAnimation(.easeInOut(duration: 0.2))
                            {
                                self.hovered = hovered
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .fileImporter(
                        isPresented: $project_export_panel_presented,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: false
                    )
                    { result in
                        switch result
                        {
                        case .success(let urls):
                            if let url = urls.first
                            {
                                stc.make_industrial_project(list: stc.package_info.build_modules_list, to: url, option: project_export_option)
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                }
                .overlay(alignment: .bottom)
                {
                    Text("Industrial Project")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.bottom, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    AppDevTile(stc: StandardTemplateConstruct())
        .frame(width: 320, height: 224)
        .padding(32)
}
