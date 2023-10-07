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
    //@Environment(\.modelContext) private var modelContext
    //@Query private var items: [Item]
    @Binding var document: Industrial_BuilderDocument

    var body: some View
    {
        NavigationSplitView
        {
            List
            {
                /*ForEach(items)
                { item in
                    NavigationLink
                    {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    }
                label:
                    {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)*/
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .toolbar
            {
                #if os(iOS)
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
                }
            }
        }
    detail:
        {
            Text("Select an item")
            TextEditor(text: $document.document.title)
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

#Preview
{
    ContentView(document: .constant(Industrial_BuilderDocument()))
}
