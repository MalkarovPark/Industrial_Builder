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
    
    @State var is_presented = false
    
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
                        if selection == .ComponentsView
                        {
                            DisclosureGroup
                            {
                                NavigationLink(destination: ModelsListView())
                                {
                                    Label("Models", systemImage: "cube")
                                        .badge(base_stc.models_nodes.count)
                                }
                                NavigationLink(destination: KinematicsListView())
                                {
                                    Label("Kinematics", systemImage: "point.3.connected.trianglepath.dotted")
                                        .badge(base_stc.kinematic_groups.count)
                                }
                                NavigationLink(destination: ChangerModulesEditor(document: $document)
                                    .onChange(of: base_stc.changer_modules)
                                    { _, new_value in
                                        document.changer_modules = new_value
                                    })
                                {
                                    Label("Changer", systemImage: "wand.and.rays")
                                        .badge(base_stc.changer_modules.count)
                                }
                            }
                            label:
                            {
                                #if os(macOS)
                                NavigationLink(destination: ComponentsView(document: $document))
                                {
                                    Label(selection.localizedName, systemImage: selection.image_name)
                                }
                                #else
                                Text(selection.localizedName)
                                    .font(.headline)
                                #endif
                            }
                        }
                        else if selection == .ObjectsView
                        {
                            DisclosureGroup
                            {
                                NavigationLink(destination: EmptyView())
                                {
                                    Label("Robots", systemImage: "r.circle")
                                }
                                NavigationLink(destination: EmptyView())
                                {
                                    Label("Tools", systemImage: "hammer.circle")
                                }
                                NavigationLink(destination: EmptyView())
                                {
                                    Label("Parts", systemImage: "shippingbox.circle")
                                }
                            }
                            label:
                            {
                                #if os(macOS)
                                NavigationLink(destination: EmptyView())
                                {
                                    Label(selection.localizedName, systemImage: selection.image_name)
                                }
                                #else
                                Text(selection.localizedName)
                                    .font(.headline)
                                #endif
                            }
                        }
                        else
                        {
                            NavigationLink
                            {
                                switch selection
                                {
                                case .PackageView:
                                    PackageView(document: $document)
                                case .BuildView:
                                    BuildView()
                                default:
                                    EmptyView()
                                }
                            }
                            label:
                            {
                                Label(selection.localizedName, systemImage: selection.image_name)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                #if os(macOS)
                .navigationSplitViewColumnWidth(min: 150, ideal: 150)
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
    case PackageView, ComponentsView, ObjectsView, BuildView //Sidebar items
    
    var id: Int { rawValue }
    var localizedName: LocalizedStringKey //Names of sidebar items
    {
        switch self
        {
        case .PackageView:
            return "Package"
        case .ComponentsView:
            return "Components"
        case .ObjectsView:
            return "Objects"
        case .BuildView:
            return "Build"
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
        case .ObjectsView:
            "square.on.circle"
        case .BuildView:
            "hammer"
        }
    }
}

#Preview
{
    ContentView(document: .constant(STCDocument()))
}
