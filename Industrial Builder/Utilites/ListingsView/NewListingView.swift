//
//  NewListingView.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 09.04.2024.
//

import SwiftUI
import IndustrialKit

struct NewListingView: View
{
    @Binding var is_presented: Bool
    
    @State private var new_file_name = ""
    
    @EnvironmentObject var base_stc: StandardTemplateConstruct
    @EnvironmentObject var document_handler: DocumentUpdateHandler
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            TextField("Name", text: $new_file_name)
                .padding(.trailing)
                .frame(minWidth: 96)
            
            Button("Add")
            {
                add_listing()
                is_presented = false
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }
    
    private func add_listing()
    {
        if new_file_name == ""
        {
            new_file_name = "Name"
        }
        
        let new_name = mismatched_name(name: new_file_name, names: base_stc.listings_files_names)
        
        base_stc.listings.append("")
        base_stc.listings_files_names.append(new_name)
        
        document_handler.document_update_listings()
    }
}

#Preview
{
    NewListingView(is_presented: .constant(true))
}
