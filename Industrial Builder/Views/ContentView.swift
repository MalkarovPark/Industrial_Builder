//
//  ContentView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 06.10.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View
{
    @Binding var document: STCDocument
    
    @State var first_loaded = true
    @State var sidebar_selection: navigation_item? = .PackageView //Selected sidebar item
    
    @StateObject private var base_stc = StandardTemplateConstruct()

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
                            //Text("Item at \(selection.image_name)")
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
                    .onDelete(perform: deleteItems)
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
        .environmentObject(base_stc)
    }

    private func addItem()
    {
        withAnimation
        {
            //let newItem = Item(timestamp: Date())
            //modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet)
    {
        withAnimation
        {
            for index in offsets
            {
                //modelContext.delete(items[index])
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

struct WindowFramer: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
        #if os(macOS)
            .frame(minWidth: 640, idealWidth: 800, minHeight: 480, idealHeight: 600) //Window sizes for macOS
        #else
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct SheetFramer: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
        #if os(macOS)
            .frame(minWidth: 640, maxWidth: 800, minHeight: 480, maxHeight: 600)
        #elseif os(visionOS)
            .frame(width: 512, height: 512)
        #endif
    }
}

struct ViewCloseButton: ViewModifier
{
    @Binding var is_presented: Bool
    
    public func body(content: Content) -> some View
    {
        content
            .overlay(alignment: .topLeading)
            {
                Button(action: { is_presented.toggle() })
                {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)
                .padding()
            }
    }
}

struct TextFrame: ViewModifier
{
    public func body(content: Content) -> some View
    {
        content
            .frame(minHeight: 64)
        #if os(macOS)
            .shadow(radius: 1)
        #endif
    }
}

#Preview
{
    ContentView(document: .constant(STCDocument()))
}

