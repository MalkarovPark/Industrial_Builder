//
//  PrepareForDevView.swift
//  Industrial Builder
//
//  Created by Artem Malkarov on 26.04.2025.
//

import SwiftUI

struct PrepareForDevView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //.padding()
        .toolbar
        {
            ToolbarItem(placement: .confirmationAction)
            {
                Button("Export")
                {
                    //external_export_panel_presented = true
                }
                /*.fileImporter(isPresented: $external_export_panel_presented,
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
                }*/
            }
        }
    }
}

#Preview
{
    PrepareForDevView()
}
