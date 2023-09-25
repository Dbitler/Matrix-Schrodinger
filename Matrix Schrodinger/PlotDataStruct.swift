//
//  PlotDataStruct.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/25/23.

import Foundation
import Charts

struct PlotDataStruct: Identifiable {
    var id: Double { xVal }
    let xVal: Double
    let yVal: Double
}
