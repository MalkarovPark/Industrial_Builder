//
//  CodeSelectorView.swift
//  Industrial Builder
//
//  Created by Artem on 09.11.2024.
//

import SwiftUI
import IndustrialKitUI

struct CodeSelectorView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @Binding var is_presented: Bool
    
    private var on_tap: (String) -> Void
    
    private var avaliable_template_names: [String] = []
    
    private var view_templates: Bool = false
    private let view_listings: Bool = true
    private let view_misc: Bool = true
    
    #if !os(visionOS)
    private let top_spacing: CGFloat = 48
    private let bottom_spacing: CGFloat = 0//40
    #else
    private let top_spacing: CGFloat = 96
    private let bottom_spacing: CGFloat = 44
    #endif
    
    public init(
        is_presented: Binding<Bool>,
        avaliable_template_names: [String] = [],
        on_tap: @escaping (String) -> Void
    )
    {
        self._is_presented = is_presented
        
        self.avaliable_template_names = avaliable_template_names
        if avaliable_template_names.count > 0
        {
            view_templates = true
        }
        
        self.on_tap = on_tap
    }
    
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 64, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 72, maximum: .infinity), spacing: 16)]
    #endif
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ScrollView(.vertical)
            {
                Spacer(minLength: top_spacing)
                
                VStack(spacing: 0)
                {
                    if avaliable_template_names.count > 0 && view_templates
                    {
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Templates")
                                .font(.title3)
                            
                            LazyVGrid(columns: columns, spacing: 16)
                            {
                                ForEach(avaliable_template_names, id: \.self)
                                { name in
                                    CodeTileView(
                                        name: name,
                                        symbol_name: "curlybraces",
                                        text: import_text_data(from: name)
                                    )
                                    {
                                        on_tap(process_template(name: name, type: .template))
                                        is_presented = false
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if base_stc.listing_items.count > 0 && view_listings
                    {
                        VStack(alignment: .leading, spacing: 8)
                        {
                            Text("Listings")
                                .font(.title3)
                            
                            LazyVGrid(columns: columns, spacing: 16)
                            {
                                ForEach(base_stc.listing_items)
                                { item in
                                    CodeTileView(
                                        name: item.name,
                                        text: item.text
                                    )
                                    {
                                        on_tap(process_template(name: item.name, type: .listing))
                                        is_presented = false
                                    }
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
                                        symbol_name: function.symbol_name
                                    )
                                    {
                                        on_tap(process_template(name: function.rawValue, type: .misc))
                                        is_presented = false
                                    }
                                }
                                .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        //.padding(.bottom, 16)
                    }
                }
                .padding()
            }
        }
        .modifier(SheetCaption(is_presented: $is_presented, label: "Select Code", plain: false))
        #if os(macOS)
        .frame(minWidth: 420, maxWidth: 600, minHeight: 480, maxHeight: 512)
        #elseif os(visionOS)
        .frame(width: 600, height: 600)
        #endif
    }
    
    private func process_template(name: String, type: TemplateType) -> String
    {
        switch type
        {
        case .none:
            return String()
        case .template:
            return import_text_data(from: name)
        case .listing:
            return base_stc.listing_items.first(where: { $0.name == name })?.text ?? String()
        case .misc:
            return base_stc.misc_code_process(type: MiscCodeGenerationFunction(rawValue: name) ?? .blank)
        }
    }
}

private struct CodeTileView: View
{
    let name: String
    let symbol_name: String?
    let text: String?
    
    let on_tap: () -> Void
    
    @State private var hovered = false
    
    public init(
        name: String,
        symbol_name: String? = nil,
        text: String? = nil,
        on_tap: @escaping () -> ()
    )
    {
        self.name = name
        self.symbol_name = symbol_name
        self.text = text
        
        self.on_tap = on_tap
    }
    
    var body: some View
    {
        Button { on_tap() }
        label:
        {
            ZStack
            {
                Rectangle()
                #if !os(visionOS)
                    .foregroundStyle(.white)
                #else
                    .foregroundStyle(.black.opacity(0.25))
                #endif
                    .overlay(alignment: .topLeading)
                {
                    if let text = text
                    {
                        Text(text)
                        #if os(macOS)
                            .font(.custom("Menlo", size: 10 / 2))
                        #else
                            .font(.custom("Menlo", size: 14 / 2))
                        #endif
                            .foregroundStyle(symbol_name == nil ? .secondary : .tertiary)
                    }
                    
                    if let symbol_name = symbol_name
                    {
                        Image(systemName: symbol_name)
                            .resizable()
                            .foregroundStyle(.tertiary)
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.light)
                            .padding()
                    }
                }
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
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .foregroundStyle(.thinMaterial)
                        }
                        .padding(2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .offset(y: hovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .background
        {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .foregroundStyle(.black)
                .blur(radius: 16 / 4)
                .opacity(0.2 / 4)
        }
        .aspectRatio(contentMode: .fit)
        .onHover
        { hovered in
            withAnimation(.easeInOut(duration: 0.2))
            {
                self.hovered = hovered
            }
        }
    }
}

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
    CodeSelectorView(is_presented: .constant(true))
    { _ in
        
    }
    .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    ZStack
    {
        CodeTileView(name: "UwU", symbol_name: "text.justify.left") {}
    }
}
