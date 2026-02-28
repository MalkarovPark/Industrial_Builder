//
//  ContentView.swift
//  Industrial Builder
//
//  Created by Artem on 06.10.2023.
//

import SwiftUI

struct ContentView: View
{
    @Binding var document: STCDocument
    let document_url: URL?
    
    @State var first_loaded = true
    @State var sidebar_selection: navigation_item? = .PackageView // Selected sidebar item
    
    @StateObject private var base_stc = StandardTemplateConstruct()
    @StateObject private var document_handler = DocumentUpdateHandler()
    
    @ViewBuilder var body: some View
    {
        Sidebar(document: $document)
            .environmentObject(base_stc)
        #if os(iOS) || os(visionOS)
            .navigationBarHidden(true)
        #endif
            .onAppear
            {
                base_stc.document_view(document, document_url)
            }
            .modifier(DocumentUpdateModifier(document: $document, base_stc: base_stc))
            .environmentObject(document_handler)
    }
}

struct Sidebar: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var components_section_expanded = true
    @State private var objects_section_expanded = true
    
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontal_size_class // Horizontal window size handler
    #endif
    
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
                            #if os(macOS)
                            DisclosureGroup(isExpanded: $components_section_expanded)
                            {
                                ComponentsSidebarGroup()
                            }
                            label:
                            {
                                NavigationLink(destination: ComponentsView().modifier(WindowFramer()))
                                {
                                    if !components_section_expanded
                                    {
                                        Label(selection.localizedName, systemImage: selection.image_name)
                                            .badge(components_count)
                                    }
                                    else
                                    {
                                        Label(selection.localizedName, systemImage: selection.image_name)
                                    }
                                }
                            }
                            #else
                            Section(isExpanded: $components_section_expanded)
                            {
                                ComponentsSidebarGroup()
                            }
                            header:
                            {
                                Text(selection.localizedName)
                                    .badge(components_count)
                            }
                            #endif
                        }
                        else if selection == .ModulesView
                        {
                            #if os(macOS)
                            DisclosureGroup(isExpanded: $objects_section_expanded)
                            {
                                ModulesSidebarGroup()
                            }
                            label:
                            {
                                NavigationLink(destination: ModulesView().modifier(WindowFramer()))
                                {
                                    if !objects_section_expanded
                                    {
                                        Label(selection.localizedName, systemImage: selection.image_name)
                                            .badge(modules_count)
                                    }
                                    else
                                    {
                                        Label(selection.localizedName, systemImage: selection.image_name)
                                    }
                                }
                            }
                            #else
                            Section(isExpanded: $objects_section_expanded)
                            {
                                ModulesSidebarGroup()
                            }
                            header:
                            {
                                Text(selection.localizedName)
                                    .badge(modules_count)
                            }
                            #endif
                        }
                        else
                        {
                            NavigationLink
                            {
                                switch selection
                                {
                                case .PackageView:
                                    PackageView(document: $document)
                                        .modifier(WindowFramer())
                                default:
                                    EmptyView()
                                        .modifier(WindowFramer())
                                }
                            }
                            label:
                            {
                                Label(selection.localizedName, systemImage: selection.image_name)
                            }
                        }
                    }
                }
                #if !os(macOS)
                .navigationTitle("STC")
                .navigationBarTitleDisplayMode(.inline)
                /*.sheet(isPresented: $app_state.settings_view_presented)
                {
                    SettingsView(setting_view_presented: $app_state.settings_view_presented)
                        .environmentObject(app_state)
                        .onDisappear
                    {
                        app_state.settings_view_presented = false
                    }
                    #if os(visionOS)
                    .frame(width: 512, height: 512)
                    #endif
                }*/
                #else
                .navigationSplitViewColumnWidth(min: 150, ideal: 160, max: 180)
                #endif
                .listStyle(.sidebar)
            }
            detail:
            {
                Text("Select an item")
                    .font(.largeTitle)
                    .modifier(WindowFramer())
                #if os(macOS)
                    .foregroundColor(Color(NSColor.quaternaryLabelColor))
                #else
                    .foregroundColor(Color(UIColor.quaternaryLabel))
                #endif
                    .padding(16)
            }
        }
    }
    
    private var components_count: Int
    {
        base_stc.entity_items.count + base_stc.image_items.count + base_stc.listing_items.count// + base_stc.kinematic_groups.count
    }
    
    private var modules_count: Int
    {
        base_stc.robot_modules.count + base_stc.tool_modules.count + base_stc.part_modules.count + base_stc.changer_modules.count
    }
}

struct ComponentsSidebarGroup: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        NavigationLink(destination: EntityListView().modifier(WindowFramer()))
        {
            Label("Scenes", systemImage: "cube")
                .badge(base_stc.entity_items.count)
        }
        
        NavigationLink(destination: ImageListView().modifier(WindowFramer()))
        {
            Label("Images", systemImage: "photo")
                .badge(base_stc.image_items.count)
        }
        
        NavigationLink(destination: ListingListView().modifier(WindowFramer()))
        {
            Label("Listings", systemImage: "scroll")
                .badge(base_stc.listing_items.count)
        }
        
        /*NavigationLink(destination: KinematicsListView().modifier(WindowFramer()))
        {
            Label("Kinematics", systemImage: "point.3.connected.trianglepath.dotted")
                .badge(base_stc.kinematic_groups.count)
        }*/
    }
}

struct ModulesSidebarGroup: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        /*NavigationLink(destination: RobotModulesView().modifier(WindowFramer()))
        {
            Label("Robot", systemImage: "r.square")
                .badge(base_stc.robot_modules.count)
        }
        NavigationLink(destination: ToolModulesView().modifier(WindowFramer()))
        {
            Label("Tool", systemImage: "hammer")
                .badge(base_stc.tool_modules.count)
        }*/
        NavigationLink(destination: PartModulesView().modifier(WindowFramer()))
        {
            Label("Part", systemImage: "shippingbox")
                .badge(base_stc.part_modules.count)
        }
        NavigationLink(destination: ChangerModulesView().modifier(WindowFramer()))
        {
            Label("Changer", systemImage: "wand.and.rays")
                .badge(base_stc.changer_modules.count)
        }
    }
}

enum navigation_item: Int, Hashable, CaseIterable, Identifiable
{
    case PackageView, ComponentsView, ModulesView // Sidebar items
    
    var id: Int { rawValue }
    var localizedName: LocalizedStringKey // Names of sidebar items
    {
        switch self
        {
        case .PackageView:
            return "Package"
        case .ComponentsView:
            return "Components"
        case .ModulesView:
            return "Modules"
        }
    }
    
    var image_name: String // Names of sidebar items symbols
    {
        switch self
        {
        case .PackageView:
            "gift"
        case .ComponentsView:
            "square.stack.3d.down.forward"
        case .ModulesView:
            "puzzlepiece.extension"
        }
    }
}

func numeral_endings(_ count: Int, word: String) -> String
{
    count == 1 ? "\(count) \(word)" : "\(count) \(word)s"
}

#Preview
{
    ContentView(document: .constant(STCDocument()), document_url: nil)
}
