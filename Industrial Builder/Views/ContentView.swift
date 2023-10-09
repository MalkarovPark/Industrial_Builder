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
                            PackageView()
                        case .ComponentsView:
                            PackageView()
                        case .PreferencesView:
                            PackageView()
                        case .ProgramsView:
                            PackageView()
                        case .TargetsView:
                            PackageView()
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
            .toolbar
            {
                /*#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    EditButton()
                }
                #endif
                ToolbarItem
                {
                    Button(action: addItem)
                    {
                        Label("Add Item", systemImage: "plus")
                    }
                }*/
            }
        }
    detail:
        {
            //Text("Select an item")
            TextEditor(text: $base_stc.package.title)
        }
        .onAppear
        {
            base_stc.document_view(document.package)
        }
        .onChange(of: base_stc.package.title)
        { oldValue, newValue in
            if first_loaded
            {
                first_loaded = false
            }
            else
            {
                document.package.title = newValue
            }
        }
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
    case PackageView, ComponentsView, PreferencesView, ProgramsView, TargetsView //Sidebar items
    
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
