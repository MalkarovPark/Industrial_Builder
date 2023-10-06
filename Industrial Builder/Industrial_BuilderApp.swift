//
//  Industrial_BuilderApp.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 06.10.2023.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct Industrial_BuilderApp: App
{
    var body: some Scene
    {
        DocumentGroup(editing: .itemDocument, migrationPlan: Industrial_BuilderMigrationPlan.self)
        {
            ContentView()
        }
    }
}

extension UTType
{
    static var itemDocument: UTType
    {
        UTType(importedAs: "com.example.item-document")
    }
}

struct Industrial_BuilderMigrationPlan: SchemaMigrationPlan
{
    static var schemas: [VersionedSchema.Type] = [
        Industrial_BuilderVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct Industrial_BuilderVersionedSchema: VersionedSchema
{
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
