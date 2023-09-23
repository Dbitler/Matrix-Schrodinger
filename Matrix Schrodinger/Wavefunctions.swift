//
//  Wavefunctions.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
//
//HAVE TO ADD UI, AND ADD CALLS TO FUNCTIONS UTILIZED, AND ALSO ADD OTHER POTENTIALS.

import SwiftUI
//This class holds the wavefunctions of the hamiltonian.

class Wavefunctions: ObservableObject {
    
    @Published var wavefxnData : [[Double]] = []
    @Published var xfxnData : [Double] = []
    @Published var wavefxnNumberData = 100
    @Published var xMin = 0.0
    @Published var xMax = 10.0
    @Published var xStep = 0.05
    @Published var Length = 2.0
    
    //populates the wave function data waveforms with the wave functions for particle in a box calculations
    //normalized wave fucntion for a particel in a 1d box is:
    // psi = sqrt(2/L) * sin((n*pi*x)/L). n = wavefxnNumber, L is the total length of xMax-xMin, and x = each individual point (x+xStep)
    // this function populates the Wavefxn array with all of the data points along Length for each value of N, giving different waveforms
    
    func wavefxnPopulate() {
        Length = xMax - xMin
        let Norm_constant = sqrt(2.0 / Length)
        var indiv_wavefxn : [Double] = []
        for x in stride(from:xMin, through:xMax, by: xStep){
            xfxnData.append(x)
        }
        for i in 0..<wavefxnNumberData{
            indiv_wavefxn.removeAll()
            let Schr_constant = (Double(i) * Double.pi) / Length
            for item in xfxnData{
                var psi_x =  Norm_constant * sin(Schr_constant * item)
                indiv_wavefxn.append(psi_x)
            }
            wavefxnData.append(indiv_wavefxn)
        }
    }
    //Gonna have to diagnalize the hamiltonian matrix
    

}
