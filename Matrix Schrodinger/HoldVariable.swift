//
//  HoldVariable.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/25/23.
//

import SwiftUI

class HoldVariable: ObservableObject {
    
    @ObservedObject private var calculator = CalculatePlotData()
    @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @Published var outsideData = [(xPoint: Double, yPoint: Double)]()
    @Published var pickerAnswers = [Double]()
    @Published var pickerAnswerText = "jeff"
    
    
    
    enum Orientation: String, CaseIterable, Identifiable {
        case Square_well, Linear_well, Parabolic_Well, Square_barrier, Squarelinear_barrier, Triangle_barrier, Coupled_Parabolic_Well, Coupled_Square_Well_Field, Harmonic_Oscillator, Kronig_penney, Variable_Kronig, KP2_a
        var id: Self { self }
    }
    enum Plot: String, CaseIterable, Identifiable {
        case Potential, Wave_Function
        var id: Self { self }
    }
    @Published var selectedOrientation: Orientation = .Square_well
    @Published var selectedPlot: Plot = .Potential
    
}
