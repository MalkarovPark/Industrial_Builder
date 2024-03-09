//
//  ContentView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 06.10.2023.
//

import SwiftUI

struct ContentView: View
{
    @Binding var document: STCDocument
    
    @State var first_loaded = true
    @State var sidebar_selection: navigation_item? = .PackageView //Selected sidebar item
    
    @StateObject private var base_stc = StandardTemplateConstruct()
    
    @ViewBuilder var body: some View
    {
        Sidebar(document: $document)
            .environmentObject(base_stc)
        #if os(iOS) || os(visionOS)
            .navigationBarHidden(true)
        #endif
    }
}

struct Sidebar: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            NavigationSplitView
            {
                List
                {
                    ForEach(navigation_item.allCases)
                    { selection in
                        NavigationLink
                        {
                            switch selection
                            {
                            case .PackageView:
                                PackageView(document: $document)
                            case .ComponentsView:
                                ComponentsView(document: $document)
                            case .PreferencesView:
                                Text(selection.localizedName)
                            case .AppView:
                                AppView(document: $document)
                            case .ProgramsView:
                                Text(selection.localizedName)
                            case .TargetsView:
                                TargetsView()
                            }
                        }
                    label:
                        {
                            Label(selection.localizedName, systemImage: selection.image_name)
                        }
                    }
                }
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                #endif
            }
        detail:
            {
                Text("Select an item")
                    .font(.largeTitle)
                #if os(macOS)
                    .foregroundColor(Color(NSColor.quaternaryLabelColor))
                #else
                    .foregroundColor(Color(UIColor.quaternaryLabel))
                #endif
                    .padding(16)
            }
            .onAppear
            {
                base_stc.document_view(document.package, images: document.images, changer_modules: document.changer_modules, tool_modules: document.tool_modules, kinematic_groups: document.kinematic_groups)
            }
        }
    }
}

enum navigation_item: Int, Hashable, CaseIterable, Identifiable
{
    case PackageView, ComponentsView, PreferencesView, AppView, ProgramsView, TargetsView //Sidebar items
    
    var id: Int { rawValue }
    var localizedName: LocalizedStringKey //Names of sidebar items
    {
        switch self
        {
        case .PackageView:
            return "Package"
        case .ComponentsView:
            return "Components"
        case .PreferencesView:
            return "Preferences"
        case .AppView:
            return "App"
        case .ProgramsView:
            return "Programs"
        case .TargetsView:
            return "Targets"
        }
    }
    
    var image_name: String //Names of sidebar items symbols
    {
        switch self
        {
        case .PackageView:
            "shippingbox"
        case .ComponentsView:
            "square.stack.3d.down.forward"
        case .PreferencesView:
            "slider.horizontal.2.square.on.square"
        case .AppView:
            "app.badge.checkmark"
        case .ProgramsView:
            "scroll"
        case .TargetsView:
            "target"
        }
    }
}

#Preview
{
    ContentView(document: .constant(STCDocument()))
}
