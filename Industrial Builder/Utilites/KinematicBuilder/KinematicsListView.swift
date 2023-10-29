//
//  KinematicsListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 25.10.2023.
//

import SwiftUI
import IndustrialKit

struct KinematicsListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    @State private var add_kinematic_view_presented = false
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(base_stc.kinematic_groups.indices, id: \.self)
                    { index in
                        StandardCard(name: base_stc.kinematic_groups[index].name, image_name: "gearshape.2.fill", color: color_from_string(base_stc.kinematic_groups[index].type.rawValue))
                        { is_presented in
                            KinematicEditorView(is_presented: is_presented, kinematic: $base_stc.kinematic_groups[index])
                        }
                    }
                }
                .padding(20)
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
        .onChange(of: base_stc.kinematic_groups)
        { oldValue, newValue in
            print("💎")
        }
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
    
    var body: some View
    {
        VStack
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
            
            HStack(spacing: 12)
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
        .padding(12)
    }
    
    private func add_kinematic_group()
    {
        if new_item_name == ""
        {
            new_item_name = "None"
        }
        
        //modules_items.append(ChangerModule(name: new_module_name))
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
