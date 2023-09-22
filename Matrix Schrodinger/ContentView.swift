//
//  ContentView.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
/* Write a program that calculates the solution to the 1D Shrodinger Equation using the matrix form of the equation. Expand in terms of the known 1D particle in a box solutions to solve the matrix equation. The program should be able to load in an arbitrary 1D potential to be solved. Use the same example potentials from Problem 4.
 
 1d particle in a box = infinite square well, but have to expand to other potentials. Infinite square well has a potential energy of 0.
 */
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
