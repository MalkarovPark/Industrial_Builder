//
//  BuildProgressView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI

struct BuildProgressView: View
{
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            
            VStack//(spacing: 0)
            {
                ProgressView(
                    value: base_stc.build_progress,
                    total: base_stc.build_total,
                    label:
                    {
                        Text("Modules build")
                    },
                    currentValueLabel:
                    {
                        Text(base_stc.build_info)
                    }
                )
                
                HStack(spacing: 0)
                {
                    Spacer()
                    
                    Button("Cancel")
                    {
                        base_stc.cancel_build()
                    }
                }
            }
            .padding()
            .background(.bar)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(width: 224)
        }
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}

#Preview
{
    BuildProgressView()
        .environmentObject(StandardTemplateConstruct())
}
