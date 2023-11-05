//
//  ModelsListView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 04.11.2023.
//

import SwiftUI
import IndustrialKit

struct ModelsListView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 24)]
    
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(spacing: 0)
            {
                LazyVGrid(columns: columns, spacing: 24)
                {
                    ForEach(base_stc.models_nodes.indices, id: \.self)
                    { number in
                        ModelCard(node: $base_stc.models_nodes[number], name: "Model \(number)") { is_presented in
                            ModelView(node: $base_stc.models_nodes[number])
                                .modifier(WindowFramer())
                                .modifier(ViewCloseButton(is_presented: is_presented))
                        }
                    }
                }
                .padding(20)
            }
        }
        .modifier(WindowFramer())
    }
}

#Preview
{
    ModelsListView()
}
