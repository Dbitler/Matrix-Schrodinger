//
//  ContentView.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
/* Write a program that calculates the solution to the 1D Shrodinger Equation using the matrix form of the equation. Expand in terms of the known 1D particle in a box solutions to solve the matrix equation. The program should be able to load in an arbitrary 1D potential to be solved. Use the same example potentials from Problem 4.
 
 1d particle in a box = infinite square well, but have to expand to other potentials. Infinite square well has a potential energy of 0.
 
 embedded in square well, expand potential out in form of square well.
 
 Hamiltonian * phi = [h-bar^2/2m d^2/dx^2 + V(x)] * Phi
 
 <1|H|1> = E    integral psi* psi H dx
 */

//HAVE TO ADD UI, and 
import SwiftUI
import Charts

struct ContentView: View {
    
    
    @EnvironmentObject var plotData :PlotClass
    @ObservedObject var myholdvariableinstance = HoldVariable()
    @ObservedObject private var calculator = CalculatePlotData()
    @ObservedObject var mypotentialinstance = Potentials()
    @ObservedObject var mywavefxnvariableinstance = Wavefunctions()
    @ObservedObject var myhamiltonianinstance = Hamiltonian()
    @ObservedObject var myenergiesinstance = Energies()
    
    @State var isChecked:Bool = false
    @State var tempInput = ""
    @State var selector = 0
    @State var outputText = ""
    @MainActor func setObjectWillChange(theObject:PlotClass){
        
        theObject.objectWillChange.send()
        
    }
    @MainActor func setupPlotDataModel(selector: Int){
        
        calculator.plotDataModel = self.plotData.plotArray[selector]
    }
    @State var delta_xstring = "0.05"
    @State var delta_x = 0.005
    @State var x_max = 10.0
    @State var x_min = 0.0
    @State var x_maxstring = "10.0"
    @State var x_minstring = "0.0"
    @State var E0string = "0.0" //E0 is an input
    @State var E_maxstring = "30.0" //E would be an input.
    @State var E0 = 0.0
    @State var E_max = 30.0
    @State var E_step = 0.005
    @State var E_stepstring = "0.05" //also an input.
    @State var wave_numberstring = "100"
    @State var wave_number = 100
    @State var plotType = ""
    
    var body: some View {
        HStack{
            VStack {
                Text("Enter length parameters")
                HStack {
                    TextField("x-step", text: $delta_xstring)
                    TextField("x-min", text: $x_minstring)
                    TextField("x-max", text: $x_maxstring)
                }
                Text("Enter energy parameters")
                HStack {
                    TextField("E-step", text: $E_stepstring)
                    TextField("E-min", text: $E0string)
                    TextField("E-max", text: $E_maxstring)
                }
                Text("Enter number of wavefunctions in expansion")
                HStack {
                    TextField("# of Wavefunctions", text: $wave_numberstring)
    
                }
                HStack{
                    VStack{
                        List {
                            Picker("Plot", selection: $myholdvariableinstance.selectedPlot) {
                                Text("Potential").tag(HoldVariable.Plot.Potential)

                                Text("Wave Function").tag(HoldVariable.Plot.Wave_Function)
                            }
                        }
                    }
                    VStack{
                        List {
                            Picker("Potential", selection: $myholdvariableinstance.selectedOrientation) {
                                Group{
                                    Text("Square Well").tag(HoldVariable.Orientation.Square_well)
                                    Text("Linear Well").tag(HoldVariable.Orientation.Linear_well)
                                    Text("Parabolic Well").tag(HoldVariable.Orientation.Parabolic_Well)
                                    Text("Square + Linear Well").tag(HoldVariable.Orientation.Squarelinear_barrier)
                                }
                                Group{
                                    Text("Square Barrier").tag(HoldVariable.Orientation.Square_barrier)
                                    Text("Triangle Barrier").tag(HoldVariable.Orientation.Triangle_barrier)
                                    Text("Coupled Parabolic Well").tag(HoldVariable.Orientation.Coupled_Parabolic_Well)
                                    // Text("Coupled Square Well + Field").tag(HoldVariable.Orientation.Coupled_Square_Well_Field)
                                    Text("Harmonic Oscillator").tag(HoldVariable.Orientation.Harmonic_Oscillator)
                                    // Text("Kronig + Penney").tag(HoldVariable.Orientation.Kronig_penney)
                                    // Text("Variable Kronig - Penney").tag(HoldVariable.Orientation.Variable_Kronig)
                                    // Text("KP2-a").tag(HoldVariable.Orientation.KP2_a)
                                }
                                
                            }
                        }
                    }
                
                }
                
                  Button(action: self.graph) {
                    Text("Calculate")
                }
                Button(action: self.printAnswers) {
                    Text("PrintAnswers")
                }
            }
        
            VStack{
                Chart($plotData.plotArray[selector].plotData.wrappedValue) {
                    LineMark(
                        x: .value("Energy", $0.xVal),
                        y: .value("Functional", $0.yVal)
                        //need to remove this reference to the Functional. -DB FIX
                    )
                    .foregroundStyle($plotData.plotArray[selector].changingPlotParameters.lineColor.wrappedValue)
                    PointMark(x: .value("Position", $0.xVal), y: .value("Height", $0.yVal))
                    
                        .foregroundStyle($plotData.plotArray[selector].changingPlotParameters.lineColor.wrappedValue)
                    
                    
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartYScale(domain: $plotData.plotArray[selector].changingPlotParameters.yMin.wrappedValue...$plotData.plotArray[selector].changingPlotParameters.yMax.wrappedValue)
                .padding()
                Text($plotData.plotArray[selector].changingPlotParameters.xLabel.wrappedValue)
                    .foregroundColor(.red)
                Text("Zeroes of the Function: ")
                TextEditor(text: $outputText)
            }
            
            
        }
    }
    
    func printAnswers(){
        print($mypotentialinstance.PotentialData.wrappedValue)
        
    }
    func graph(){
        outputText = ""
        delta_x = Double(delta_xstring)!
         E0 = Double(E0string)!
        E_max = Double(E_maxstring)!
        E_step = Double(E_stepstring)!
        x_max = Double(x_maxstring)!
        x_min = Double(x_minstring)!
        wave_number = Int(wave_numberstring)!
        let length = x_max - x_min
        //call on wavefunction first, then potentials, then that allows you to populate your hamiltoniana nd diagonalize.
        
        
        mypotentialinstance.PotentialData = []
        mywavefxnvariableinstance.wavefxnData = []
        mywavefxnvariableinstance.xfxnData = []
        mypotentialinstance.getPotential(potentialType: myholdvariableinstance.selectedOrientation.rawValue, xMin: x_min, xMax: x_max, xStep: self.delta_x)
        
        
        mywavefxnvariableinstance.wavefxnPopulate(xMin: x_min, xMax: x_max, xStep: delta_x, length: length, wavefxnNumberData: wave_number)
        myenergiesinstance.En_populate(xMin: x_min, xMax: x_max, xStep: delta_x, length: length, principleqnumber: wave_number)
        
    //these just make sure that the individual classes are calling the same instance of the same class, and not duplicates
        myhamiltonianinstance.mywavefxninstance = mywavefxnvariableinstance
        myhamiltonianinstance.myenergyinstance = myenergiesinstance
        myhamiltonianinstance.mypotentialinstance = mypotentialinstance
        
        myhamiltonianinstance.Ham_populate(xMin: x_min, xMax: x_max, xStep: delta_x, length: length)
        
        //used to make sure that the diagonalization actually works. 
       // outputText = myhamiltonianinstance.Ham_diagonalize()
        myhamiltonianinstance.Ham_diagonalize(wavefxnNumberData: wave_number)
        
        //after hamiltonian is diagonalized, call upon this function to calculate the final wave function
        myhamiltonianinstance.calcfinalwavefxn(coefficientcount: wave_number)
        
        //use this for loop to find the wavefunctions for each of the energies. 

//        myholdvariableinstance.pickerAnswers = answers
//
//        for item in answers {
//            outputText += "Energy = \(item) eV\n"
//
//        }
//
        
       // calculateExtrapolatedDifference(functionToDifferentiate: (Double,Double) -> Double, x: energy, h: 0.00001, C: C)
        self.plotData.plotArray[0].plotData = []
        calculator.plotDataModel = self.plotData.plotArray[0]
        
        
        let plotType = myholdvariableinstance.selectedPlot.rawValue
        
        
        switch plotType {
        // Just graphing the Potential and the Wave Function, not the functional
        case "Potential":
            for m in 0...mypotentialinstance.PotentialData.count-1{
                calculator.appendDataToPlot(plotData: [(x: mypotentialinstance.PotentialData[m].xPoint, y: mypotentialinstance.PotentialData[m].PotentialPoint)])
            }
            calculator.plotDataModel!.changingPlotParameters.yMax = 20.0
            calculator.plotDataModel!.changingPlotParameters.yMin = -5.0
            
//        case "Wave_Function": //Doesn't work as is, just outputs garbage data.
//            for m in 0...mywavefxnvariableinstance.wavefxnData.count-1{
//                calculator.appendDataToPlot(plotData: [(x: mywavefxnvariableinstance.wavefxnData[m].xPoint, y: mywavefxnvariableinstance.wavefxnData[m].PsiPoint)])
//            }
        default:
            Text("plot Type Error")
        }
        
        setObjectWillChange(theObject: self.plotData)

        
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
