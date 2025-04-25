//
//  ExternalModulesBuildView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

struct ExternalModulesBuildView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var selected_name = String()
    
    @Binding var document: STCDocument
    
    @State private var external_export_panel_presented = false
    @State private var internal_export_panel_presented = false
    
    #if os(iOS)
    // MARK: Horizontal window size handler
    @Environment(\.horizontalSizeClass) private var horizontal_size_class
    #endif
    
    @State private var is_compact = false
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            BuildListView(selected_name: $selected_name)
                .padding(.bottom)
            
            Button("Build")
            {
                external_export_panel_presented = true
            }
            .buttonStyle(.borderedProminent)
            .fileImporter(isPresented: $external_export_panel_presented,
                          allowedContentTypes: [.folder],
                          allowsMultipleSelection: false)
            { result in
                switch result
                {
                case .success(let urls):
                    if let url = urls.first
                    {
                        base_stc.build_external_modules(list: selected_list, to: url)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
        .padding()
        .onChange(of: base_stc.package_info.build_modules_lists)
        { _, new_value in
            document.package_info.build_modules_lists = new_value
        }
        .onAppear
        {
            if base_stc.package_info.build_modules_lists.count > 0
            {
                selected_name = base_stc.package_info.build_modules_lists_names.first ?? ""
            }
        }
        .overlay
        {
            if base_stc.on_building_modules// || true
            {
                BuildProgressView()
            }
        }
    }
    
    private var selected_list: BuildModulesList
    {
        guard let index = base_stc.package_info.build_modules_lists.firstIndex(where: { $0.name == selected_name })
        else
        {
            return BuildModulesList(name: "")
        }
        return base_stc.package_info.build_modules_lists[index]
    }
}

#Preview {
    ExternalModulesBuildView(document: .constant(STCDocument()))
        .environmentObject(StandardTemplateConstruct())
        .frame(width: 256)
}
