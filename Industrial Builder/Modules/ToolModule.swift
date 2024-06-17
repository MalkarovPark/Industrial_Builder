//
//  ToolModule.swift
//  Industrial Builder
//
//  Created by Artem on 11.04.2024.
//

import Foundation
import IndustrialKit

public class ToolModule: IndustrialModule
{
    public var operation_codes = [OperationCode]()
    
    //MARK: - Work with file system
    public init(name: String = String(), description: String = String(), package_file_name: String = String(), is_internal_change: Bool = Bool(), internal_code: String = String())
    {
        super.init(name: name, description: description, package_file_name: package_file_name)
        code_items = [
            //Model Controller
            CodeItem(name: "nodes_connect"),
            CodeItem(name: "nodes_perform"),
            CodeItem(name: "reset_model"),
            
            //Model Statistics
            CodeItem(name: "model_charts_data"),
            CodeItem(name: "model_clear_charts_data"),
            CodeItem(name: "model_states_data"),
            CodeItem(name: "model_clear_states_data"),
            
            //Connector
            CodeItem(name: "connection_process"),
            CodeItem(name: "disconnection_process"),
            
            CodeItem(name: "perform"),
            CodeItem(name: "pause_operations"),
            
            //Model Statistics
            CodeItem(name: "charts_data"),
            CodeItem(name: "clear_charts_data"),
            CodeItem(name: "states_data"),
            CodeItem(name: "clear_states_data")
        ]
    }
    
    //MARK: Codable handling
    required public init(from decoder: any Decoder) throws
    {
        try super.init(from: decoder)
    }
}

public struct ToolControllerModule: Equatable, Codable
{
    var connect = ""
    var reset = ""
    var other = ""
    
    var statistics = StatisticsFunctionsData()
}

public struct ToolConnectorModule: Equatable, Codable
{
    var connect = ""
    var disconnect = ""
    var other = ""
    
    var statistics = StatisticsFunctionsData()
}

public struct StatisticsFunctionsData: Equatable, Codable
{
    var chart_code = ""
    var chart_code_clear = ""
    
    var state_code = ""
    var state_code_clear = ""
    
    var other_code = ""
}

public struct OperationCode: Equatable, Codable
{
    var value = 0
    var name = ""
    var symbol = "questionmark"
    
    //var code = ""
    var controller_code = ""
    var connector_code = ""
}

//MARK: - File
/*public struct FileHolder: Equatable
{
    public static func == (lhs: FileHolder, rhs: FileHolder) -> Bool
    {
        lhs.name == rhs.name
    }
    
    var name = String()
    var data = (Any).self
}*/
