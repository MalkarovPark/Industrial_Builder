//
//  ProcessView.swift
//  Industrial Builder
//
//  Created by Artem on 25.04.2025.
//

import SwiftUI
import IndustrialKit

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
                                ProcessItemView(title: "Files", subtitle: "Export to separated modules files")
                                {
                                    ZStack
                                    {
                                        #if !os(visionOS)
                                        Rectangle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: .white, location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "F1F2FA"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #else
                                        Circle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: .white, location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "F1F2FA"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #endif
                                        
                                        Image(systemName: "folder.fill")
                                            .foregroundStyle(.cyan)
                                            .font(.system(size: 20))
                                            //.imageScale(.large)
                                    }
                                }
                            })
                            .navigationTitle("Process")
                        
                        NavigationLink(destination: InternalModulesBuildView(document: $document)
                            .navigationTitle("App"), label: {
                                ProcessItemView(title: "App",
                                                subtitle: "Make a project with internal modules")
                                {
                                    ZStack
                                    {
                                        #if !os(visionOS)
                                        Rectangle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: Color(hex: "8BCAC9"), location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "4EA3A3"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #else
                                        Circle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: Color(hex: "8BCAC9"), location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "4EA3A3"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #endif
                                        
                                        Image(systemName: "cube.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20))
                                            //.imageScale(.large)
                                            .scaleEffect(x: 1, y: -1)
                                            .opacity(0.5)
                                    }
                                }
                            })
                        
                        NavigationLink(destination: PrepareForDevView()
                            .navigationTitle("Development"), label: {
                                ProcessItemView(title: "Development",
                                                subtitle: "Prepare industrial application project")
                                {
                                    ZStack
                                    {
                                        #if !os(visionOS)
                                        Rectangle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: Color(hex: "262626"), location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "262626"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #else
                                        Circle()
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(stops: [
                                                        Gradient.Stop(color: Color(hex: "262626"), location: 0.0),
                                                        Gradient.Stop(color: Color(hex: "262626"), location: 1.0)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .scaledToFill()
                                        #endif
                                        
                                        Image(systemName: "terminal")
                                            .foregroundStyle(.white)
                                            .imageScale(.large)
                                    }
                                }
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
        #if os(macOS)
        .toolbar
        {
            ToolbarItem(placement: .cancellationAction)
            {
                Button("Dismiss")
                {
                    is_presented = false
                }
            }
        }
        #endif
    }
}

struct ProcessItemView<Content: View>: View
{
    let title: String
    let subtitle: String
    let content: () -> Content
    
    var body: some View
    {
        HStack
        {
            ZStack
            {
                content()
                    .scaledToFit()
            }
            #if os(macOS)
            .frame(width: 40, height: 40)
            #else
            .frame(width: 48, height: 48)
            #endif
            #if !os(visionOS)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            #endif
            .shadow(color: .black.opacity(0.1), radius: 6)
            //.shadow(color: .black.opacity(0.05), radius: 4)
            
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
        .glassEffect(in: .rect(cornerRadius: 16.0))
        #else
        .padding(.vertical, 8)
        #endif
        .frame(maxWidth: .infinity)
    }
}

#Preview
{
    ProcessView(document: .constant(STCDocument()), is_presented: .constant(true))
        .frame(width: 320, height: 400)
}

#Preview
{
    ProcessItemView(title: "Packages", subtitle: "None", content: {
        EmptyView()
    })
    .frame(width: 256)
}
