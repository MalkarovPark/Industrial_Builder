//
//  KinematicInspectorView.swift
//  Industrial Builder
//
//  Created by Artem on 05.11.2024.
//

import SwiftUI
import IndustrialKit
import IndustrialKitUI

struct KinematicInspectorView: View
{
    @Binding var elements: [KinematicElement]

    @State private var expanded = [false, false, false]

    @EnvironmentObject var app_state: AppState
    @EnvironmentObject var document_handler: DocumentUpdateHandler

    var body: some View
    {
        VStack(spacing: 0)
        {
            List
            {
                Section("Parameters")
                {
                    ForEach(elements.indices, id: \.self)
                    { index in
                        KinematicElementView(element: $elements[index])
                        {
                            app_state.update_robot_kinematic(elements)
                            document_handler.document_update_kinematics()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .modifier(ListBorderer())
            .padding()
            
            List
            {
                Section("Origin Shift")
                {
                    #if !os(visionOS)
                    OriginShiftView(shift: $app_state.kinematic_preview_robot.origin_shift)
                    #else
                    VStack
                    {
                        OriginShiftView(shift: $app_state.kinematic_preview_robot.origin_shift)
                    }
                    #endif
                }
            }
            .listStyle(.plain)
            .modifier(ListBorderer())
            .padding([.horizontal, .bottom])
            #if !os(visionOS)
            .frame(height: 160)
            #else
            .frame(height: 240)
            #endif
        }
        #if os(visionOS)
        .frame(width: 400)
        #endif
        .onAppear
        {
            app_state.update_robot_kinematic(elements)
        }
    }
}

struct KinematicElementView: View
{
    @Binding var element: KinematicElement
    
    var on_update: () -> Void
    
    var body: some View
    {
        HStack(spacing: 12)
        {
            Text(element.name)
            TextField("0", value: $element.value, formatter: NumberFormatter())
            #if os(macOS)
            .textFieldStyle(.squareBorder)
            #endif
            Stepper("", value: $element.value)
                .labelsHidden()
        }
        .onChange(of: element.value)
        { _, _ in
            on_update()
        }
    }
}

public struct OriginShiftView: View
{
    @Binding var shift: (x: Float, y: Float, z: Float)
    
    let on_update: () -> ()
    
    @State private var editor_selection = 0
    
    public init(shift: Binding<(x: Float, y: Float, z: Float)>, on_update: @escaping () -> () = {})
    {
        self._shift = shift
        self.on_update = on_update
    }
    
    public var body: some View
    {
        HStack(spacing: 12)
        {
            Text("X")
            TextField("0", value: $shift.x, format: .number)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
            .textFieldStyle(.squareBorder)
            #endif
            Stepper("Enter", value: $shift.x, in: -20000...20000)
                .labelsHidden()
        }
        .onChange(of: ShiftSnapshot(shift))
        { _, _ in
            on_update()
        }
        
        HStack(spacing: 12)
        {
            Text("Y")
            TextField("0", value: $shift.y, format: .number)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
            .textFieldStyle(.squareBorder)
            #endif
            Stepper("Enter", value: $shift.y, in: -20000...20000)
                .labelsHidden()
        }
        .onChange(of: ShiftSnapshot(shift))
        { _, _ in
            on_update()
        }
        
        HStack(spacing: 12)
        {
            Text("Z")
            TextField("0", value: $shift.z, format: .number)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
            .textFieldStyle(.squareBorder)
            #endif
            Stepper("Enter", value: $shift.z, in: -20000...20000)
                .labelsHidden()
        }
        .onChange(of: ShiftSnapshot(shift))
        { _, _ in
            on_update()
        }
    }
}

public struct ShiftSnapshot: Equatable
{
    let x: Float, y: Float, z: Float
    
    public init(_ tuple: (x: Float, y: Float, z: Float))
    {
        self.x = tuple.x
        self.y = tuple.y
        self.z = tuple.z
    }
}

#Preview
{
    KinematicInspectorView(elements: .constant([KinematicElement(name: "L1", value: 160.0)]))
        .frame(width: 256, height: 480)
        .environmentObject(AppState())
        
}
