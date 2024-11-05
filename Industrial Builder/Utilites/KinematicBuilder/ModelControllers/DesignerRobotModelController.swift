//
//  DesignerRobotModelController.swift
//  Industrial Builder
//
//  Created by Artem on 05.11.2024.
//

import Foundation
import IndustrialKit

class DesignerRobotModelController: RobotModelController
{
    ///Model nodes lengths.
    public var lengths = [Float]()
    
    /**
     Required count of lengths to transform the connected model.
     
     Сan be overridden depending on the number of lengths used in the transformation.
     */
    open var description_lengths_count: Int { 0 }
    
    ///Sets new values for connected nodes geometries.
    open func update_nodes_lengths()
    {
        
    }
    
    ///Updates connected model nodes scales by instance lengths.
    public final func nodes_transform()
    {
        guard lengths.count == description_lengths_count //Return if current lengths count is not equal required one
        else
        {
            return
        }
        
        update_nodes_lengths()
    }
    
    /**
     Updates connected model nodes scales by lengths.
     
     - Parameters:
        - lengths: The new model nodes lengths.
     */
    public func transform_by_lengths(_ lengths: [Float])
    {
        if lengths.count > 0
        {
            self.lengths = lengths
            nodes_transform()
        }
    }
}
