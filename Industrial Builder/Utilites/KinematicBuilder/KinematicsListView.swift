//
//  KinematicsListView.swift
//  Industrial Builder
//
//  Created by Artem on 25.10.2023.
//

import SwiftUI
import IndustrialKit

struct KinematicsListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    @State private var add_kinematic_view_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 96, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            if base_stc.kinematic_groups.count > 0
            {
                ScrollView(.vertical)
                {
                    LazyVGrid(columns: columns, spacing: 24)
                    {
                        ForEach(base_stc.kinematic_groups.indices, id: \.self)
                        { index in
                            KinematicCard(group: base_stc.kinematic_groups[index])
                            {
                                KinematicDesignerView(group: $base_stc.kinematic_groups[index])
                            }
                            .contextMenu
                            {
                                Button(role: .destructive, action: {
                                    delete_kinematic(base_stc.kinematic_groups[index].id)
                                })
                                {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .aspectRatio(1, contentMode: .fill)
                        }
                    }
                    .padding(20)
                    // .padding(.vertical)
                }
            }
            else
            {
                ContentUnavailableView
                {
                    Label("No Kinematics", systemImage: "point.3.connected.trianglepath.dotted")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar
        {
            Button (action: { add_kinematic_view_presented = true })
            {
                Label("Add Kinematic", systemImage: "plus")
            }
            #if os(visionOS)
            .buttonBorderShape(.circle)
            #endif
            .popover(isPresented: $add_kinematic_view_presented, arrowEdge: .bottom)
            {
                AddKinematicView(is_presented: $add_kinematic_view_presented, items: $base_stc.kinematic_groups)
            }
        }
    }
    
    private func delete_kinematic(_ id: UUID)
    {
        // base_stc.kinematic_groups.remove(at: index)
        base_stc.kinematic_groups.removeAll { $0.id == id }
        document_handler.document_update_kinematics()
    }
}

func kinematics_names(_ modules: [KinematicGroup]) -> [String]
{
    var names = [String]()
    for module in modules
    {
        names.append(module.name)
    }
    
    return names
}

struct AddKinematicView: View
{
    @Binding var is_presented: Bool
    @Binding var items: [KinematicGroup]
    
    @State private var new_item_name = ""
    @State private var kinematic_preset: KinematicGroupType = .portal
    
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                TextField("Name", text: $new_item_name)
                    .frame(minWidth: 128, maxWidth: 256)
                #if os(iOS) || os(visionOS)
                    .frame(idealWidth: 256)
                    .textFieldStyle(.roundedBorder)
                #endif
            }
            .padding(.bottom)
            
            HStack(spacing: 0)
            {
                Picker("Type", selection: $kinematic_preset)
                {
                    ForEach(KinematicGroupType.allCases, id: \.self)
                    { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                #if os(macOS)
                .buttonStyle(.bordered)
                #elseif os(iOS)
                .modifier(PickerBorderer())
                #endif
                #if os(macOS)
                .frame(width: 128)
                #endif
                .padding(.trailing)
                
                Button("Add", action: add_kinematic_group)
                    .fixedSize()
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func add_kinematic_group()
    {
        if new_item_name == ""
        {
            new_item_name = "Name"
        }
        
        switch kinematic_preset
        {
        /*case .none:
            items.append(KinematicGroup(name: mismatched_name(name: new_item_name, names: kinematics_names(items))))*/
        case ._6DOF:
            items.append(_6DOFGroupMake(name: mismatched_name(name: new_item_name, names: kinematics_names(items))))
        case .portal:
            items.append(PortalGroupMake(name: mismatched_name(name: new_item_name, names: kinematics_names(items))))
        }
        
        is_presented = false
        document_handler.document_update_kinematics()
    }
}

#Preview
{
    KinematicsListView()
        .environmentObject(StandardTemplateConstruct())
}

#Preview
{
    AddKinematicView(is_presented: .constant(true), items: .constant([KinematicGroup]()))
}
