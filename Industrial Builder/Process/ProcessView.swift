//
//  ProcessView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI

struct ProcessView: View
{
    #if os(macOS)
    private let columns: [GridItem] = [.init(.adaptive(minimum: 160, maximum: .infinity), spacing: 16)]
    #else
    private let columns: [GridItem] = [.init(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)]
    #endif
    
    @Binding var document: STCDocument
    @Binding var is_presented: Bool
    
    var body: some View
    {
        NavigationStack
        {
            ScrollView(.vertical)
            {
                VStack(spacing: 0)
                {
                    LazyVGrid(columns: columns, spacing: 16)
                    {
                        NavigationLink(destination: ExternalModulesBuildView(document: $document)
                            .navigationTitle("Files"), label: {
                                ProcessItemView(title: "Files", subtitle: "Export to separated modules files", image: Image("build_to_files_icon"))
                            })
                        
                        NavigationLink(destination: ExternalModulesBuildView(document: $document)
                            .navigationTitle("App"), label: {
                                ProcessItemView(title: "App",
                                              subtitle: "Make a project with internal modules",
                                              image: Image("build_to_app_icon"))
                            })
                        
                        /*Button(action: {  })
                        {
                            ProcessItemView(title: "Files", subtitle: "Export to separated modules files", image: Image("build_to_files_icon"))
                        }
                        
                        Button(action: {  })
                        {
                            ProcessItemView(title: "App",
                                          subtitle: "Make a project with internal modules",
                                          image: Image("build_to_app_icon"))
                        }*/
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Process")
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction)
            {
                Button("Cancel")
                {
                    is_presented = false
                }
            }
        }
        /*#else
        .navigationBarItems(trailing: Button("Cancel") {
            is_presented = false
        })*/
        #endif
    }
}

struct ProcessItemView: View
{
    let title: String
    let subtitle: String
    let image: Image
    
    var body: some View
    {
        HStack
        {
            ZStack
            {
                // Rectangle()
                    // .foregroundStyle(Color.accentColor)
                image
                    .resizable()
                    // .scaledToFill()
                    .scaledToFit()
                    .foregroundStyle(.white)
            }
            #if os(macOS)
            .frame(width: 40, height: 40)
            #else
            .frame(width: 48, height: 48)
            #endif
            // .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading)
            {
                Text(title)
                
                Text(subtitle)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .padding(.trailing, 8)
        }
        #if os(iOS)
        .padding(10)
        #else
        .padding(.vertical, 8)
        #endif
        .frame(maxWidth: .infinity)
    }
}

#Preview
{
    ProcessView(document: .constant(STCDocument()), is_presented: .constant(true))
}

#Preview
{
    ProcessItemView(title: "Packages", subtitle: "None", image: Image(systemName: "cube.fill"))
}
