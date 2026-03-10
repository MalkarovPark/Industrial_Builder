//
//  InfoView.swift
//  Industrial Builder
//
//  Created by Artem on 10.05.2024.
//

import SwiftUI

import IndustrialKit
import IndustrialKitUI

struct InfoView: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            LazyVGrid(columns: columns, spacing: 24)
            {
                DescriptionCard(stc: base_stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 256)
                
                ExportCard(stc: base_stc, on_update: { document_handler.document_update_info() })
                    .frame(height: 256)
                
                GlassPaneCard()//color: Color(hex: "9D80FF"))
                    .frame(height: 256)
                
                GlassPaneCard()//color: Color(hex: "9D80FF"))
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
        GlassPaneCard()
        {
            let description = Binding(
                get: { stc.package_info.description },
                set:
                    { new_value in
                        stc.package_info.description = new_value
                        
                        on_update()
                    }
            )
            
            VStack(alignment: .leading, spacing: 12)
            {
                Text("Description")
                    .font(.system(size: 24, design: .rounded))
                    .foregroundStyle(.quaternary)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                
                TextEditor(text: description)
                    .textEditorStyle(.plain)
                    .font(.title3)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

private struct ExportCard: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    let on_update: () -> ()
    
    @State private var selected_name: DeviceMode = .internal_modules
    
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
            VStack(alignment: .leading, spacing: 12)
            {
                Text("Modules")
                    .font(.system(size: 24, design: .rounded))
                    .foregroundStyle(.quaternary)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                
                let sn = Binding(
                    get: { selected_name.rawValue },
                    set:
                        { _ in
                            
                        }
                )
                
                /*if base_stc.robot_modules.isEmpty && base_stc.tool_modules.isEmpty && base_stc.part_modules.isEmpty && base_stc.changer_modules.isEmpty
                {
                    Text("No modules for export")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }*/
                
                BuildListView(stc: stc, selected_name: sn, with_spacer: true, on_update: on_update)
                    .overlay(alignment: .bottom)
                {
                    HStack
                    {
                        Picker("Mode", selection: $selected_name)
                        {
                            ForEach(DeviceMode.allCases, id: \.self)
                            { device_mode in
                                Text(device_mode.title).tag(device_mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                        .labelsHidden()
                        .disabled(stc.package_info.build_modules_lists.count == 0)
                        
                        switch selected_name
                        {
                        case .internal_modules:
                            Picker(selection: $stc.internal_export_type, label: Text("Export Type"))
                            {
                                ForEach(InternalExportType.allCases, id: \.self)
                                { export_type in
                                    Text(export_type.rawValue).tag(export_type)
                                }
                            }
                        case .external_modules:
                            Picker(selection: $stc.external_export_type, label: Text("Export Type"))
                            {
                                ForEach(ExternalExportType.allCases, id: \.self)
                                { export_type in
                                    Text(export_type.rawValue).tag(export_type)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(.bar)
                }
            }
        }
    }
}

#Preview
{
    InfoView(document: .constant(STCDocument()))
        .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600)
        .environmentObject(StandardTemplateConstruct())
}
