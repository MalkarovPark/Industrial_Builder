//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem on 10.05.2024.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI
import UniformTypeIdentifiers

struct InfoView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            LazyVGrid(columns: columns, spacing: 24)
            {
                DescriptionCard(stc: stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 256)
                
                ModulesCard(stc: stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 256)
                
                ExternalExportCard(stc: stc)
                    .frame(height: 256)
                
                DevelopmentCard(stc: stc)
                    .frame(height: 256)
            }
            .padding(20)
        }
    }
}

public struct GlassPaneCard<Content: View>: View
{
    let color: Color?
    let content: Content?
    
    public init(
        color: Color? = nil,
        @ViewBuilder content: () -> Content? = { EmptyView() }
    )
    {
        self.color = color
        self.content = content()
    }
    
    public var body: some View
    {
        ZStack
        {
            if let color = color
            {
                let gradient = Gradient(stops: [
                    Gradient.Stop(color: color.opacity(0.4), location: 0.0),
                    Gradient.Stop(color: color.opacity(0.2), location: 1.0)
                ])
                
                ZStack
                {
                    Rectangle()
                        .foregroundStyle(color.opacity(0.5))
                    
                    Rectangle()
                        .foregroundStyle(gradient)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: color.opacity(0.5), radius: 16)
            }
            else
            {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 16)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                Gradient.Stop(color: .gray.opacity(0.06), location: 0.0),
                                Gradient.Stop(color: .gray.opacity(0.04), location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct DescriptionCard: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    let on_update: () -> ()
    
    var body: some View
    {
        GlassPaneCard(color: .accentColor)
        {
            ScrollView
            {
                let description = Binding(
                    get: { stc.package_info.description },
                    set:
                        { new_value in
                            stc.package_info.description = new_value
                            
                            on_update()
                        }
                )
                
                TextEditor(text: description)
                    .textEditorStyle(.plain)
                    .font(.title3)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(.white)
                
                Spacer(minLength: 52)
            }
            .overlay(alignment: .bottom)
            {
                HStack
                {
                    Text("Description")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
                .background(.ultraThinMaterial)
            }
        }
    }
}

private struct ModulesCard: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    let on_update: () -> ()
    
    enum DeviceMode: String, CaseIterable
    {
        case internal_modules = "internal_modules"
        case external_modules = "external_modules"
        
        var title: String
        {
            switch self
            {
            case .internal_modules: "Internal Modules"
            case .external_modules: "External Modules"
            }
        }
    }
    
    var body: some View
    {
        GlassPaneCard()
        {
            if stc.any_modules_avaliable
            {
                ScrollView
                {
                    BuildListView(stc: stc, on_update: on_update)
                    
                    Spacer(minLength: 52)
                }
                .overlay(alignment: .bottom)
                {
                    VStack
                    {
                        HStack
                        {
                            Text("Modules")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 12)
                                .padding(.leading, 16)
                            
                            Spacer()
                        }
                    }
                    .background(.ultraThinMaterial)
                }
            }
            else
            {
                Text("No Modules")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

private struct ExternalExportCard: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    @State private var is_export_presented = false
    
    @State private var external_export_panel_presented = false
    
    enum DeviceMode: String, CaseIterable
    {
        case internal_modules = "Internal Modules"
        case external_modules = "External Modules"
    }
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        GlassPaneCard(color: Color(hex: "3671D9"))
        {
            ZStack
            {
                Menu
                {
                    ForEach(ExternalExportType.allCases, id: \.self)
                    { export_type in
                        Button(export_type.rawValue)
                        {
                            stc.external_export_type = export_type
                            external_export_panel_presented = true
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
                            
                            Image(systemName: "folder.fill")
                                .foregroundStyle(Color(hex: "6CC0FF"))
                                .font(.system(size: 30))
                        }
                        .overlay(alignment: .bottomTrailing)
                        {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 12))
                                .padding(8)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(!stc.any_modules_avaliable)
                .fileImporter(
                    isPresented: $external_export_panel_presented,
                    allowedContentTypes: [.folder],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            stc.build_external_modules(list: stc.package_info.build_modules_list, to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom)
            {
                HStack
                {
                    Text("External Export")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
            }
        }
    }
}

private struct DevelopmentCard: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    @State private var code_template_view_presented = false
    @State private var store_listing_panel_presented = false
    @State private var store_mbk_panel_presented = false
    @State private var passed_listing_text = String()
    
    @State private var project_export_panel_presented = false
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        GlassPaneCard(color: Color(hex: "13C5B5"))
        {
            HStack(spacing: 18)
            {
                Menu
                {
                    ForEach(PrepareForDevType.allCases, id: \.self)
                    { export_type in
                        Button(export_type.rawValue)
                        {
                            stc.prepare_for_dev_type = export_type
                            switch export_type
                            {
                            case .from_listing: code_template_view_presented = true
                            case .mbk_only: store_mbk_panel_presented = true
                            }
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
                        .overlay(alignment: .bottomTrailing)
                        {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.white.opacity(0.75))
                                .font(.system(size: 12))
                                .padding(8)
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
                .fileImporter(
                    isPresented: $store_mbk_panel_presented,
                    allowedContentTypes: [.folder],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            stc.store_mbk(to: url)
                        }
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
                
                Button
                {
                    project_export_panel_presented = true
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
                            stc.build_application_project(list: stc.package_info.build_modules_list, to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
                /*Button
                {
                    
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
                                            Gradient.Stop(color: Color(hex: "FFAD5A"), location: 0.0),
                                            Gradient.Stop(color: Color(hex: "DD3D4D"), location: 1.0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .scaledToFill()
                            
                            Image(systemName: "swift")
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
                                .font(.system(size: 40))
                                .offset(x: -2, y: -2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .fileImporter(
                    isPresented: $external_export_panel_presented,
                    allowedContentTypes: [.folder],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            stc.build_external_modules(list: stc.package_info.build_modules_list, to: url)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }*/
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom)
            {
                HStack
                {
                    Text("Industrial App")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
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

struct IconView<Content: View>: View
{
    let content: () -> Content
    
    var body: some View
    {
        ZStack
        {
            content()
                .scaledToFit()
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}

