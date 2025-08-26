//
//  CodeBuilderView.swift
//  Industrial Builder
//
//  Created by Artem on 09.11.2024.
//

import SwiftUI
#if os(iOS)
import IndustrialKit
#endif

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
    
    #if !os(macOS)
    private var bottom_view: AnyView = AnyView(EmptyView())
    #endif
    
    #if os(macOS)
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
    #else
    public init<V: View>(is_presented: Binding<Bool>, avaliable_templates_names: [String] = [], bottom_view: V = AnyView(EmptyView()), process_template: @escaping (String) -> Void)
    {
        self._is_presented = is_presented
        
        self.avaliable_templates_names = avaliable_templates_names
        if avaliable_templates_names.count > 0
        {
            view_templates = true
        }
        
        self.process_template = process_template
        
        self.bottom_view = AnyView(bottom_view)
    }
    #endif
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 72, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                if avaliable_templates_names.count > 0 && view_templates
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Templates")
                            .font(.title3)
                        
                        LazyVGrid(columns: columns, spacing: 16)
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
                    .padding(.bottom, 16)
                }
                
                if base_stc.listings_files_names.count > 0 && view_listings
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Listings")
                            .font(.title3)
                        
                        LazyVGrid(columns: columns, spacing: 16)
                        {
                            ForEach(base_stc.listings_files_names, id: \.self)
                            { name in
                                CodeTileView(
                                    name: name,
                                    image_name: "text.justify.left",
                                    is_selected: is_template_selected(name: name, type: .listing)
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                if MiscCodeGenerationFunction.allCases.count > 0 && view_misc
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("Other")
                            .font(.title3)
                        
                        LazyVGrid(columns: columns, spacing: 16)
                        {
                            ForEach(MiscCodeGenerationFunction.allCases, id: \.self)
                            { function in
                                CodeTileView(
                                    name: function.rawValue,
                                    image_name: function.image_name,
                                    is_selected: is_template_selected(name: function.rawValue, type: .misc)
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    //.padding(.bottom, 16)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(macOS)
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
        #endif
        #if !os(macOS)
        .modifier(BottomToolbarModifier(bottom_view:
                                            HStack(spacing: 0)
                                        {
            bottom_view
            
            Spacer()
            
            Button("Cancel")
            {
                is_presented = false
            }
            .padding(.trailing)
            
            Button("Confirm")
            {
                is_presented = false
                if let confirmed_template = template
                {
                    process_template(confirmed_template)
                }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
            .disabled(selected_template_name == nil)
        }
            .padding()
                                       ))
        #endif
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
                .foregroundStyle(.ultraThinMaterial)
                .shadow(radius: is_selected ? 4 : 0)
                .overlay(alignment: .bottomTrailing)
                {
                    Text(name)
                    #if os(macOS)
                        .font(.system(size: 8))
                    #else
                        .font(.system(size: 10))
                    #endif
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
                .fontWeight(.light)
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
                        .fontWeight(.light)
                }
                #if os(macOS)
                .frame(width: 40, height: 40)
                #else
                .frame(width: 48, height: 48)
                #endif
                .background(.ultraThinMaterial)
            }
        }
        .scaleEffect(is_selected ? 1 : 0.95)
        .onTapGesture
        {
            is_selected.toggle()
        }
        .animation(.easeInOut(duration: 0.2), value: is_selected)
        .aspectRatio(1, contentMode: .fit)
    }
}

#if !os(macOS)
struct ToolSubbar: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
    }
}
#endif

private enum TemplateType: Equatable, CaseIterable
{
    case none
    case template
    case listing
    case misc
}

struct BottomToolbarModifier: ViewModifier
{
    var bottom_view: AnyView = AnyView(EmptyView())
    
    public init<V: View>(bottom_view: V = AnyView(EmptyView()))
    {
        self.bottom_view = AnyView(bottom_view)
    }
    
    public func body(content: Content) -> some View
    {
        VStack(spacing: 0)
        {
            content
            
            Divider()
            
            bottom_view
        }
    }
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
