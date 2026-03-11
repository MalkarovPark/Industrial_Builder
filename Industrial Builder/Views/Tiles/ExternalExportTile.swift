//
//  ExternalExportTile.swift
//  Industrial Builder
//
//  Created by Artem on 11.03.2026.
//

import SwiftUI

struct ExternalExportTile: View
{
    @ObservedObject var stc: StandardTemplateConstruct
    
    @State private var is_export_presented = false
    
    @State private var file_exporter_presented = false
    
    @State private var external_export_option: ModuleExportOption = .no_build
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        GlassTile(color: Color(hex: "3671D9"))
        {
            ZStack
            {
                Menu
                {
                    ForEach(ModuleExportOption.allCases, id: \.self)
                    { export_type in
                        Button(export_type.rawValue)
                        {
                            external_export_option = export_type
                            file_exporter_presented = true
                        }
                    }
                    
                    /*Divider()
                    
                    Button("For Project Import")
                    {
                        
                    }*/
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
                    isPresented: $file_exporter_presented,
                    allowedContentTypes: [.folder],
                    allowsMultipleSelection: false
                )
                { result in
                    switch result
                    {
                    case .success(let urls):
                        if let url = urls.first
                        {
                            stc.export_modules(list: stc.package_info.build_modules_list, to: url, option: external_export_option)
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
                    Text("Export Modules")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
            }
        }
        .overlay
        {
            if stc.on_building_modules
            {
                BuildProgressView()
            }
        }
    }
}

struct BuildProgressView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            
            VStack//(spacing: 0)
            {
                ProgressView(
                    value: base_stc.build_progress,
                    total: base_stc.build_total,
                    label:
                    {
                        Text("Modules build")
                    },
                    currentValueLabel:
                    {
                        Text(base_stc.build_info)
                    }
                )
                
                HStack(spacing: 0)
                {
                    Spacer()
                    
                    Button("Cancel")
                    {
                        base_stc.cancel_build()
                    }
                }
            }
            .padding()
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(width: 224)
        }
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}

#Preview
{
    ExternalExportTile(stc: StandardTemplateConstruct())
        .frame(width: 320, height: 192)
        .padding(32)
}

#Preview
{
    BuildProgressView()
        .environmentObject(StandardTemplateConstruct())
}
