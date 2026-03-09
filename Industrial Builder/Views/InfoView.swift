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
                DescriptionCard(document: $document)
                    .frame(maxHeight: 256)
                
                GlassPaneCard()//color: Color(hex: "9D80FF"))
                    .frame(minHeight: 256)
                
                GlassPaneCard()//color: Color(hex: "9D80FF"))
                    .frame(minHeight: 256)
                
                GlassPaneCard()//color: Color(hex: "9D80FF"))
                    .frame(minHeight: 256)
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
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var is_targeted = false
    @State private var load_panel_presented = false
    
    @State private var update_toggle = false
    
    var body: some View
    {
        GlassPaneCard()
        {
            VStack(alignment: .leading, spacing: 12)
            {
                Text("Description")
                    .font(.system(size: 24, design: .rounded))
                    .foregroundStyle(.quaternary)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                
                TextEditor(text: $base_stc.package_info.description)
                    .textEditorStyle(.plain)
                    .font(.title3)
                    .frame(maxHeight: .infinity)
                    .onChange(of: base_stc.package_info.description)
                    { _, new_value in
                        document.package_info.description = new_value
                        document_handler.document_update_info()
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
