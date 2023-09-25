//
//  ChangingPlotParameters.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/25/23.
//

import SwiftUI

class ChangingPlotParameters: NSObject, ObservableObject {
    
    //These plot parameters are adjustable
    
    var xLabel: String = "x"
    var yLabel: String = "y"
    var xMax : Double = 1.0
    var yMax : Double = 1.0
    var yMin : Double = 0.0
    var xMin : Double = 0.0
    var lineColor: Color = Color.blue
    var title: String = "Plot Title"
    
}
