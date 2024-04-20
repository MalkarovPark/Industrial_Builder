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
    
    @State var first_loaded = true
    @State var sidebar_selection: navigation_item? = .PackageView //Selected sidebar item
    
    @StateObject private var base_stc = StandardTemplateConstruct()
    @StateObject private var document_handler = DocumentUpdateHandler()
    
    @AppStorage("WorkFolderBookmark") private var work_folder_bookmark: Data?
    
    @ViewBuilder var body: some View
    {
        Sidebar(document: $document)
            .environmentObject(base_stc)
        #if os(iOS) || os(visionOS)
            .navigationBarHidden(true)
        #endif
            .onAppear
            {
                base_stc.document_view(document)
                
                if work_folder_bookmark != nil
                {
                    let scene_file_data = document.deferred_scene_view(folder_bookmark: work_folder_bookmark!)
                    base_stc.scenes = scene_file_data.scenes
                    base_stc.scenes_files_names = scene_file_data.names
                }
                
                base_stc.images_files_names = document.images_files_names
                
                //print(document.scenes_files_names)
                //print(document.images_files_names)
            }
            .modifier(DocumentUpdateModifier(document: $document, base_stc: base_stc))
            .environmentObject(document_handler)
    }
}

struct Sidebar: View
{
    @Binding var document: STCDocument
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    #if !os(macOS)
    @State private var components_section_expanded = true
    @State private var objects_section_expanded = true
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
                            DisclosureGroup
                            {
                                ComponentsSidebarGroup()
                            }
                            label:
                            {
                                NavigationLink(destination: ComponentsView())
                                {
                                    Label(selection.localizedName, systemImage: selection.image_name)
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
                            }
                            #endif
                        }
                        else if selection == .ModulesView
                        {
                            #if os(macOS)
                            DisclosureGroup
                            {
                                ModulesSidebarGroup()
                            }
                            label:
                            {
                                NavigationLink(destination: ModulesView())
                                {
                                    Label(selection.localizedName, systemImage: selection.image_name)
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
                .navigationTitle("View")
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
        }
    }
}

struct ComponentsSidebarGroup: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        NavigationLink(destination: ScenesListView())
        {
            Label("Scenes", systemImage: "cube")
                .badge(base_stc.scenes.count)
        }
        
        NavigationLink(destination: ImagesListView())
        {
            Label("Images", systemImage: "photo")
                .badge(base_stc.images.count)
        }
        
        NavigationLink(destination: ListingsListView())
        {
            Label("Listings", systemImage: "scroll")
                .badge(base_stc.listings.count)
        }
        
        NavigationLink(destination: KinematicsListView())
        {
            Label("Kinematics", systemImage: "point.3.connected.trianglepath.dotted")
                .badge(base_stc.kinematic_groups.count)
        }
    }
}

struct ModulesSidebarGroup: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        NavigationLink(destination: RobotsModulesEditor())
        {
            Label("Robots", systemImage: "r.square")
        }
        NavigationLink(destination: ToolsModulesEditor())
        {
            Label("Tools", systemImage: "hammer")
        }
        NavigationLink(destination: PartsModulesEditor())
        {
            Label("Parts", systemImage: "shippingbox")
        }
        NavigationLink(destination: ChangerModulesEditor())
        {
            Label("Changers", systemImage: "wand.and.rays")
                .badge(base_stc.changer_modules.count)
        }
    }
}

enum navigation_item: Int, Hashable, CaseIterable, Identifiable
{
    case PackageView, ComponentsView, ModulesView //Sidebar items
    
    var id: Int { rawValue }
    var localizedName: LocalizedStringKey //Names of sidebar items
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
    
    var image_name: String //Names of sidebar items symbols
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

#Preview
{
    ContentView(document: .constant(STCDocument()))
}
