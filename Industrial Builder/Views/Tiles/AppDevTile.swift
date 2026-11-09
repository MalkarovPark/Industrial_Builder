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
    
    #if os(visionOS)
    @EnvironmentObject var app_state: AppState
    #endif
    
    @State private var card_width: CGFloat = 320 / 2
    
    var body: some View
    {
        GeometryReader
        { geometry in
            GlassTile(color: Color(hex: "7886C7"))
                .overlay
            {
                ZStack
                {
                    BoxCard(color: Color(hex: "7886C7"), depth: 4, shows_shadow: false)
                        .allowsTightening(false)
                        .disabled(true)
                        .clipShape(
                            Rectangle()
                                .scale(2)
                                .offset(x: -geometry.size.width)
                        )
                    
                    BoxCard(color: Color(hex: "3F4896"), depth: 4, shows_shadow: false)
                        .allowsTightening(false)
                        .disabled(true)
                        .clipShape(
                            Rectangle()
                                .scale(2)
                                .offset(x: geometry.size.width)
                        )
                    
                    HStack(spacing: 0)
                    {
                        ZStack
                        {
                            Rectangle()
                                .fill(.clear)
                            
                            Button
                            {
                                code_template_view_presented = true
                            }
                            label:
                            {
                                TerminalIcon()
                            }
                            .buttonStyle(.plain)
                            .buttonBorderShape(.roundedRectangle(radius: 16))
                            .fileExporter(
                                isPresented: $store_listing_panel_presented,
                                document: ProjectDocument(content: passed_listing_text),
                                defaultFilename: "App"
                            )
                            { result in
                                switch result
                                {
                                case .success(let url):
                                    let file_name = url.lastPathComponent
                                    let folder_url = url.deletingLastPathComponent()
                                    
                                    stc.make_simple_app(
                                        name: file_name,
                                        data: passed_listing_text,
                                        to: folder_url
                                    )
                                    passed_listing_text = String()
                                    
                                case .failure(let error):
                                    //print(error.localizedDescription)
                                    break
                                }
                            }
                            .sheet(isPresented: $code_template_view_presented)
                            {
                                CodeSelectorView(
                                    is_presented: $code_template_view_presented,
                                    avaliable_template_names: [
                                        "ExternalRobotConnector",
                                        "ExternalToolConnector"
                                    ]
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
                            Text("Terminal App")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.bottom, 12)
                        }
                        
                        ZStack
                        {
                            Rectangle()
                                .fill(.clear)
                            
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
                                XcodeIcon()
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
                                    .onHover
                                    { hovered in
                                        withAnimation(.easeInOut(duration: 0.2))
                                        {
                                            self.hovered = hovered
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .buttonBorderShape(.roundedRectangle(radius: 16))
                            .fileExporter(
                                isPresented: $project_export_panel_presented,
                                document: ProjectDocument(content: String()),
                                defaultFilename: "Industrial App"
                            )
                            { result in
                                switch result
                                {
                                case .success(let url):
                                    let file_name = url.lastPathComponent
                                    let folder_url = url.deletingLastPathComponent()
                                    
                                    stc.make_industrial_project(
                                        name: file_name,
                                        list: stc.package_info.build_modules_list,
                                        to: folder_url,
                                        option: project_export_option
                                    )
                                    
                                case .failure(let error):
                                    //print(error.localizedDescription)
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
                    .offset(y: -4)
                }
            }
        }
        #if os(visionOS)
        .onChange(of: store_listing_panel_presented)
        { _, new_value in
            withAnimation
            {
                app_state.realitykit_volumes_hidden = new_value
            }
        }
        .onChange(of: project_export_panel_presented)
        { _, new_value in
            withAnimation
            {
                app_state.realitykit_volumes_hidden = new_value
            }
        }
        .onDisappear
        {
            withAnimation
            {
                app_state.realitykit_volumes_hidden = false
            }
        }
        #endif
    }
}

struct ProjectDocument: FileDocument
{
    static var readableContentTypes = [UTType.bundle]
    
    init(configuration: ReadConfiguration) throws
    {
        
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        return .init()
    }
    
    init(content: String = "")
    {
        
    }
}

struct TerminalIcon: View
{
    var body: some View
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
}

struct XcodeIcon: View
{
    var body: some View
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
}

#Preview
{
    AppDevTile(stc: StandardTemplateConstruct())
        .frame(width: 320, height: 224)
        .padding(32)
}
