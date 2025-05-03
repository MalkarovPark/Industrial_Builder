//
//  CodeBuilderView.swift
//  Industrial Builder
//
//  Created by Artem on 09.11.2024.
//

import SwiftUI

struct CodeBuilderView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var is_presented: Bool
    
    private var process_template: (String) -> Void
    
    private var avaliable_templates_names: [String] = []
    
    private var view_templates: Bool = false
    private let view_listings: Bool = true
    private let view_misc: Bool = true
    
    @State private var selected_template_name: String?
    @State private var selected_template_type: TemplateType = .none
    
    public init(is_presented: Binding<Bool>, avaliable_templates_names: [String] = [], process_template: @escaping (String) -> Void)
    {
        self._is_presented = is_presented
        
        self.avaliable_templates_names = avaliable_templates_names
        if avaliable_templates_names.count > 0
        {
            view_templates = true
        }
        
        self.process_template = process_template
    }
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 8)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            if avaliable_templates_names.count > 0 && view_templates
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Templates")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach(avaliable_templates_names, id: \.self)
                        { name in
                            CodeTileView(
                                name: name,
                                image_name: "curlybraces",
                                is_selected: is_template_selected(name: name, type: .template)
                            )
                        }
                    }
                }
                .padding(8)
            }
            
            if base_stc.listings_files_names.count > 0 && view_listings
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Listings")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach(base_stc.listings_files_names, id: \.self)
                        { name in
                            CodeTileView(
                                name: name,
                                image_name: "text.justify.left",
                                is_selected: is_template_selected(name: name, type: .listing)
                            )
                        }
                    }
                }
                .padding(8)
            }
            
            if MiscCodeGenerationFunction.allCases.count > 0 && view_misc
            {
                VStack(alignment: .leading, spacing: 8)
                {
                    Text("Other")
                        .font(.title3)
                    
                    LazyVGrid(columns: columns, spacing: 8)
                    {
                        ForEach(MiscCodeGenerationFunction.allCases, id: \.self)
                        { function in
                            CodeTileView(
                                name: function.rawValue,
                                image_name: function.image_name,
                                is_selected: is_template_selected(name: function.rawValue, type: .misc)
                            )
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        /*#if os(macOS) || os(visionOS)
        .fitted()
        #endif*/
        .toolbar
        {
            ToolbarItem(placement: .cancellationAction)
            {
                Button("Cancel")
                {
                    is_presented = false
                }
            }
            
            ToolbarItem(placement: .confirmationAction)
            {
                Button("Confirm")
                {
                    is_presented = false
                    if let confirmed_template = template
                    {
                        process_template(confirmed_template)
                    }
                }
                .disabled(selected_template_name == nil)
            }
        }
    }
    
    private func is_template_selected(name: String, type: TemplateType) -> Binding<Bool>
    {
        Binding<Bool>(
            get:
            {
                selected_template_name == name && selected_template_type == type
            },
            set:
            { is_selected in
                if is_selected
                {
                    selected_template_name = name
                    selected_template_type = type
                }
                else
                {
                    if selected_template_name == name && selected_template_type == type
                    {
                        selected_template_name = nil
                        selected_template_type = .none
                    }
                }
            }
        )
    }
    
    private var template: String?
    {
        switch selected_template_type
        {
        case .none:
            return nil
        case .template:
            return import_text_data(from: selected_template_name ?? "")
        case .listing:
            if let index = base_stc.listings_files_names.firstIndex(of: selected_template_name ?? "")
            {
                return base_stc.listings[index]
            }
            else
            {
                return nil
            }
        case .misc:
            return base_stc.misc_code_process(type: MiscCodeGenerationFunction(rawValue: selected_template_name ?? "") ?? .blank)
        }
    }
}

struct CodeTileView: View
{
    let name: String
    let image_name: String
    
    @Binding var is_selected: Bool
    
    public init(name: String, image_name: String, is_selected: Binding<Bool>)
    {
        self.name = name
        self.image_name = image_name
        self._is_selected = is_selected
    }
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .frame(width: 60, height: 60)
                .foregroundStyle(.ultraThinMaterial)
                .shadow(radius: is_selected ? 4 : 0)
                .overlay(alignment: .bottomTrailing)
                {
                    Text(name)
                        .font(.system(size: 8))
                        .padding(2)
                        .background
                        {
                            Rectangle()
                                .foregroundStyle(.bar)
                        }
                }
            
            Image(systemName: image_name)
                .resizable()
                .foregroundStyle(.tertiary)
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        .overlay
        {
            if is_selected
            {
                ZStack
                {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.primary)
                }
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
            }
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .frame(width: 64, height: 64)
    }
}

private enum TemplateType: Equatable, CaseIterable
{
    case none
    case template
    case listing
    case misc
}

#Preview
{
    CodeBuilderView(is_presented: .constant(true))
    { _ in
        
    }
    .background(.white)
    .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    ZStack
    {
        CodeTileView(name: "UwU", image_name: "text.justify.left", is_selected: .constant(false))
    }
    .background(.white)
}
