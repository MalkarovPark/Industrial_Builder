//
//  ChangerModule.swift
//  Industrial Builder
//
//  Created by Artem on 11.04.2024.
//

import Foundation

public class ChangerModule: IndustrialModule
{
    public var code_file_name = String()
    
    /**
     Performs register conversion within a class instance.
     - Parameters:
        - registers: A changeable registers data.
     */
    public func change(registers: inout [Float])
    {
        if code_file_name == ""
        {
            registers = internal_change(registers: registers)
        }
        else
        {
            registers = external_change(registers: registers)
        }
    }
    
    /**
     Performs register conversion within a class instance.
     - Parameters:
        - registers: A changeable registers data.
     
     The contents of this function are specified in the listing and compiled in the application.
     */
    private func internal_change(registers: [Float]) -> [Float]
    {
        /*@START_MENU_TOKEN@*/return [Float]()/*@END_MENU_TOKEN@*/
    }
    
    /**
     An itnernal code file.
     
     Impliments to the *internal_change* function by compilation.
     */
    public var internal_code = String()
    
    /**
     Performs register conversion within an external script.
     - Parameters:
        - registers: A changeable registers data.
     
     The conversion occurs by executing code in an external swift file.
     */
    private func external_change(registers: [Float]) -> [Float]
    {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["swift", "\(internal_url ?? "")/Components/Code/\(package_file_name)/\(code_file_name ?? "").swift"] + registers.map { String($0) }
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        //Converting the output back to a Float array
        let new_registers = output?.split(separator: " ").compactMap { Float($0) }
        return new_registers ?? []
    }
}

//External code file example
/*
import Foundation

if CommandLine.arguments.count > 1
{
    let inputNumbers = CommandLine.arguments.dropFirst().compactMap { Float($0) }
    let transformedNumbers = inputNumbers.map { $0 * 2 }
    print(transformedNumbers.map { String($0) }.joined(separator: " "))
}
else
{
    print("Ошибка: Необходимо передать массив чисел в качестве аргументов.")
}
*/
