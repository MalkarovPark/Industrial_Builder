//
//  ConnectionParametersView.swift
//  Industrial Builder
//
//  Created by Artem on 15.11.2024.
//

import SwiftUI
import IndustrialKit

struct ConnectionParametersView: View
{
    @Binding var connection_parameters: [ConnectionParameter]
    
    var update_file_data: () -> Void
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            List
            {
                if connection_parameters.count > 0
                {
                    ForEach($connection_parameters.indices, id: \.self)
                    { index in
                        ConnectionParameterView(parameter: $connection_parameters[index], update_file_data: update_file_data)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(ViewBorderer())
            .overlay(alignment: .center)
            {
                if !(connection_parameters.count > 0)
                {
                    Text("No connection parameters")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .controlSize(.regular)
        .padding(.bottom)
    }
}

#Preview
{
    ConnectionParametersView(connection_parameters: .constant([ConnectionParameter]()), update_file_data: {})
}
