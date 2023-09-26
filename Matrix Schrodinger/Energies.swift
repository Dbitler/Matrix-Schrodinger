//
//  Energies.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
//

import SwiftUI

class Energies: ObservableObject{
    @Published var En_matrix : [Double] = []
    //if wavefxnnumberdata goes from 0 - 100, principle quantum number goes from 1 - 101.
    
    /// //this gives us the energy values that required a rootfinder in the previous Schrodinger program, at the values where the wavefunction goes to 0. using the Square well as an example, the energies go 0.37, ~1.5, ~3.3, ~6.0... and so on.
    /// - Parameters:
    ///   - xMin: pulled from input UI
    ///   - xMax: pulled from input UI
    ///   - xStep: pulled from input UI
    ///   - length: derived from xMax-xMin, the length of the squarewell
    ///   - principleqnumber: number of total wavefunctions. utilized as "n" in the equation.
    func En_populate(xMin: Double, xMax: Double, xStep: Double, length: Double, principleqnumber: Int){
        // energy = n^2 * pi^2 * H^2 / 2mL^2, so have to make a matrix of Energies for every instance of L.
        let h_barc = 1.96E-7 // eV*s * speed of light (m/s) (1 meter = 1E10 angstrom
        let h_barcAngstrom = h_barc * 1E10
        var m_e = 510998.0 //eV
        let hbar2overm = pow(h_barcAngstrom, 2.0) / m_e
        //for 10 anstroms e_1 should be  ~0.3
        let norm_constant = (pow(Double.pi, 2) * hbar2overm) / (2 * pow(length, 2))
        // (eV*s * A/s)^2 * 1/eV * 1/A^2 = eV
        for i in 0..<principleqnumber{
            let E_n = norm_constant * (pow(Double(i+1),2))
            En_matrix.append(E_n)
        }

    }
    
    
}
