//
//  ChangerModulesListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 11.04.2024.
//

import SwiftUI
import IndustrialKit

struct ChangerModulesListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    @State private var new_panel_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.changer_modules.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.changer_modules.indices, id: \.self)
                        { index in
                            StandardSheetCard(name: base_stc.changer_modules[index].name, image_name: "star", color: .secondary)
                            { is_presented in
                                ChangerModuleView(changer: $base_stc.changer_modules[index])
                                    .frame(maxWidth: 800)
                                    .modifier(ViewCloseButton(is_presented: is_presented))
                            }
                            .contextMenu
                            {
                                Button(role: .destructive, action: {
                                    delete_changer(base_stc.changer_modules[index].id)
                                })
                                {
                                    Label("Delete", systemImage: "xmark")
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Changer Modules", systemImage: "wand.and.rays")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(WindowFramer())
        .toolbar
        {
            Button(action: { new_panel_presented.toggle() })
            {
                Image(systemName: "plus")
            }
            .popover(isPresented: $new_panel_presented, arrowEdge: .bottom)
            {
                AddNewView(is_presented: $new_panel_presented, names: changers_names())
                { new_name in
                    base_stc.changer_modules.append(ChangerModule(name: new_name))
                }
            }
        }
    }
    
    private func changers_names() -> [String]
    {
        var names = [String]()
        
        for changer_module in base_stc.changer_modules
        {
            names.append(changer_module.name)
        }
        
        return names
    }
    
    private func delete_changer(_ id: UUID)
    {
        base_stc.changer_modules.removeAll { $0.id == id }
        //document_handler.document_update_ima()
    }
}

#Preview
{
    ChangerModulesListView()
        .environmentObject(StandardTemplateConstruct())
}
