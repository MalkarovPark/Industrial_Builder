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
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
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
                            StandardNavigationCard(name: base_stc.kinematic_groups[index].name, image_name: "gearshape.2.fill", color: color_from_string(base_stc.kinematic_groups[index].type.rawValue))
                            {
                                KinematicDesignerView(group: $base_stc.kinematic_groups[index])
                            }
                            .contextMenu
                            {
                                Button(role: .destructive, action: {
                                    delete_kinematic(base_stc.kinematic_groups[index].id)
                                })
                                {
                                    Label("Delete", systemImage: "xmark")
                                }
                            }
                        }
                    }
                    .padding(20)
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
        .toolbar
        {
            Button (action: { add_kinematic_view_presented = true })
            {
                Label("Add Kinematic", systemImage: "plus")
            }
            .popover(isPresented: $add_kinematic_view_presented, arrowEdge: .bottom)
            {
                AddKinematicView(is_presented: $add_kinematic_view_presented, items: $base_stc.kinematic_groups)
            }
        }
        .modifier(WindowFramer())
    }
    
    private func delete_kinematic(_ id: UUID)
    {
        //base_stc.kinematic_groups.remove(at: index)
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
    @State private var kinematic_preset: KinematicGroupTypes = .portal
    
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
            
            HStack
            {
                Picker("Type", selection: $kinematic_preset)
                {
                    ForEach(KinematicGroupTypes.allCases, id: \.self)
                    { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                #if os(macOS)
                .frame(width: 128)
                #endif
                
                Button("Add", action: add_kinematic_group)
                    .fixedSize()
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
    
    private func add_kinematic_group()
    {
        if new_item_name == ""
        {
            new_item_name = "None"
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
