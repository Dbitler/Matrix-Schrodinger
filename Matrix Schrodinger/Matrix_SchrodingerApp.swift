//
//  Matrix_SchrodingerApp.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
//

import SwiftUI

@main
struct Matrix_SchrodingerApp: App {
    @StateObject var plotData = PlotClass()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(plotData)
                .tabItem {
                    Text("Plot")
                }
        }
    }
}
