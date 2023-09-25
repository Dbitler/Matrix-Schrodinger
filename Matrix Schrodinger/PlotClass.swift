//
//  PlotClass.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/25/23.
//

import Foundation

class PlotClass: ObservableObject {
    
    @Published var plotArray: [PlotDataClass]
    
    @MainActor init() {
        self.plotArray = [PlotDataClass.init(fromLine: true)]
        self.plotArray.append(contentsOf: [PlotDataClass.init(fromLine: true)])
            
        }

    
}
