//
//  Hamiltonian.swift
//  Matrix Schrodinger
//
//  Created by IIT PHYS 440 on 9/22/23.
//

import SwiftUI
import Accelerate

//This class contains the function to populate the Hamiltonian, the function to diagonalize the Hamiltonian, and the function to calculate the final wave function.
class Hamiltonian: ObservableObject {

    @Published var Ham_matrix : [[Double]] = []

    @ObservedObject var mywavefxninstance = Wavefunctions()
    @ObservedObject var myenergyinstance = Energies()
    @Published var resultsString = ""
    @ObservedObject var mypotentialinstance = Potentials()
    @Published var Calced_Eigenvalues : [Double] = []
    @Published var Calced_Eigenfxns : [[Double]] = []
    @Published var Calced_Wavefxns : [[Double]] = []
    
    
    func Ham_populate(xMin: Double, xMax: Double, xStep: Double, length: Double){
        var intermediary_matrix : [Double] = []
        for j in 0..<mywavefxninstance.wavefxnData.count{
            intermediary_matrix.removeAll()
            for i in 0..<mywavefxninstance.wavefxnData.count{
                //trying to calculate the <j|E|i> matrix when i = j
                // <i|E_j|j>
                var matrix_element = 0.0
                if i == j{
                    
                    matrix_element += myenergyinstance.En_matrix[i]
                }
                
                //trying to calculate the <j|V(x)|i> matrix
                //<psi(x)*_i |V(x) |psi(x)_j> = integral of psi(x)*_i V(x) psi(x)_j dx
                // integrate by Length * mean value 1/N Epsilon f(xi) one sin(i) sin(j) for every point x (FROM LANDAU)
                var average = 0.0
                for q in 0..<mypotentialinstance.Potential.count{
                    average += mywavefxninstance.wavefxnData[i][q] * mywavefxninstance.wavefxnData[j][q] * mypotentialinstance.Potential[q]
                    
                }
                let integral = (average / Double(mypotentialinstance.Potential.count)) * length
                matrix_element += integral
                intermediary_matrix.append(matrix_element)
            }
            Ham_matrix.append(intermediary_matrix)
            //gives us the hamiltonian matrix, which we will use and diagonalize. that will give us our energies, and we will have to create new wave functions. SUCCESSFULLY PRINTS A 100X100 MATRIX LETS GO
        }
    }

    
    func Ham_diagonalize(wavefxnNumberData: Int) { //need to get diagonalization to work here, or else the entire thing goes up in smoek.
        //let realStartingArray = [[2.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0], [4.0, 2.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 4.0, 2.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 4.0, 2.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 4.0, 2.0, 4.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 4.0, 2.0, 4.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 2.0, 4.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 2.0, 4.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 2.0, 4.0], [4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 2.0]]
        let realStartingArray = Ham_matrix
        
        
        var N = Int32(realStartingArray.count)
        
        var flatArray :[Double] = pack2dArray(arr: realStartingArray, rows: Int(N), cols: Int(N))
        
        resultsString += "Matrix With Real Eigenvalues\n"
        
        for item in realStartingArray {
        
            resultsString += "\(item)\n"
        }
        
        resultsString += "\n"
        
        resultsString += calculateEigenvalues(arrayForDiagonalization: flatArray, wavefxnNumberData: wavefxnNumberData)
        
            
        /* Complex Eigenvalues */
            
        resultsString += "Complex Eigenvalues Problem\n\n"
        //This returns the resultsstring obtained from the calc Eigenvalues function to the UI, and displays them
    }
    
    /// calculateEigenvalues
    ///
    /// - Parameter arrayForDiagonalization: linear Column Major FORTRAN Array for Diagonalization
    /// - Returns: String consisting of the Eigenvalues and Eigenvectors
    func calculateEigenvalues(arrayForDiagonalization: [Double], wavefxnNumberData: Int) -> String {
        /* Integers sent to the FORTRAN routines must be type Int32 instead of Int */
        //var N = Int32(sqrt(Double(startingArray.count)))
        
        var returnString = ""
        
        var N = Int32(sqrt(Double(arrayForDiagonalization.count)))
        var N2 = Int32(sqrt(Double(arrayForDiagonalization.count)))
        var N3 = Int32(sqrt(Double(arrayForDiagonalization.count)))
        var N4 = Int32(sqrt(Double(arrayForDiagonalization.count)))
        
        var flatArray = arrayForDiagonalization
        
        var error : Int32 = 0
        var lwork = Int32(-1)
        // Real parts of eigenvalues
        var wr = [Double](repeating: 0.0, count: Int(N))
        // Imaginary parts of eigenvalues
        var wi = [Double](repeating: 0.0, count: Int(N))
        // Left eigenvectors
        var vl = [Double](repeating: 0.0, count: Int(N*N))
        // Right eigenvectors
        var vr = [Double](repeating: 0.0, count: Int(N*N))
        
        
        /* Eigenvalue Calculation Uses dgeev */
        /*   int dgeev_(char *jobvl, char *jobvr, Int32 *n, Double * a, Int32 *lda, Double *wr, Double *wi, Double *vl,
         Int32 *ldvl, Double *vr, Int32 *ldvr, Double *work, Int32 *lwork, Int32 *info);*/
        
        /* dgeev_(&calculateLeftEigenvectors, &calculateRightEigenvectors, &c1, AT, &c1, WR, WI, VL, &dummySize, VR, &c2, LWork, &lworkSize, &ok)    */
        /* parameters in the order as they appear in the function call: */
        /* order of matrix A, number of right hand sides (b), matrix A, */
        /* leading dimension of A, array records pivoting, */
        /* result vector b on entry, x on exit, leading dimension of b */
        /* return value =0 for success*/
        
        
        
        /* Calculate size of workspace needed for the calculation */
        
        var workspaceQuery: Double = 0.0
        dgeev_(UnsafeMutablePointer(mutating: ("N" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &N, &flatArray, &N2, &wr, &wi, &vl, &N3, &vr, &N4, &workspaceQuery, &lwork, &error)
        
        print("Workspace Query \(workspaceQuery)")
        
        /* size workspace per the results of the query */
        
        var workspace = [Double](repeating: 0.0, count: Int(workspaceQuery))
        lwork = Int32(workspaceQuery)
        
        /* Calculate the size of the workspace */
        
        dgeev_(UnsafeMutablePointer(mutating: ("N" as NSString).utf8String), UnsafeMutablePointer(mutating: ("V" as NSString).utf8String), &N, &flatArray, &N2, &wr, &wi, &vl, &N3, &vr, &N4, &workspace, &lwork, &error)
        
        
        if (error == 0)
        {
            for index in 0..<wi.count      /* transform the returned matrices to eigenvalues and eigenvectors */
            {
                if (wi[index]>=0.0)
                {
                    //WR is the real eigenvalue component, wi is the imaginary
                    returnString += "Eigenvalue\n\(wr[index]) + \(wi[index])i\n\n"
                }
                else
                {
                    returnString += "Eigenvalue\n\(wr[index]) - \(fabs(wi[index]))i\n\n"
                }
                
                returnString += "Eigenvector\n"
                returnString += "["
                
                
                /* To Save Memory dgeev returns a packed array if complex */
                /* Must Unpack Properly to Get Correct Result
                 
                 VR is DOUBLE PRECISION array, dimension (LDVR,N)
                 If JOBVR = 'V', the right eigenvectors v(j) are stored one
                 after another in the columns of VR, in the same order
                 as their eigenvalues.
                 If JOBVR = 'N', VR is not referenced.
                 If the j-th eigenvalue is real, then v(j) = VR(:,j),
                 the j-th column of VR.
                 If the j-th and (j+1)-st eigenvalues form a complex
                 conjugate pair, then v(j) = VR(:,j) + i*VR(:,j+1) and
                 v(j+1) = VR(:,j) - i*VR(:,j+1). */
                
                for j in 0..<N
                {
                    if(wi[index]==0)
                    {
                        
                        returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) + 0.0i, \n" /* print x */
                        
                    }
                    else if(wi[index]>0)
                    {
                        if(vr[Int(index)*(Int(N))+Int(j)+Int(N)]>=0)
                        {
                            returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) + \(vr[Int(index)*(Int(N))+Int(j)+Int(N)])i, \n"
                        }
                        else
                        {
                            returnString += "\(vr[Int(index)*(Int(N))+Int(j)]) - \(fabs(vr[Int(index)*(Int(N))+Int(j)+Int(N)]))i, \n"
                        }
                    }
                    else
                    {
                        if(vr[Int(index)*(Int(N))+Int(j)]>0)
                        {
                            returnString += "\(vr[Int(index)*(Int(N))+Int(j)-Int(N)]) - \(vr[Int(index)*(Int(N))+Int(j)])i, \n"
                            
                        }
                        else
                        {
                            returnString += "\(vr[Int(index)*(Int(N))+Int(j)-Int(N)]) + \(fabs(vr[Int(index)*(Int(N))+Int(j)]))i, \n"
                            
                        }
                    }
                }
                
                /* Remove the last , in the returned Eigenvector */
                returnString.remove(at: returnString.index(before: returnString.endIndex))
                returnString.remove(at: returnString.index(before: returnString.endIndex))
                returnString.remove(at: returnString.index(before: returnString.endIndex))
                returnString += "]\n\n"
            }
        }
        else {print("An error occurred\n")}
//        @Published var Calced_Eigenvalues : [Double] = []
//        @Published var Calced_Eigenfxns : [[Double]] = []

        //this for loop attempts to create a 2D array, matching the Eigenvalues to their respective Eigenfunctions. it successfully makes the 2D array, but it is not sorted, which is unfortunate.
        var timer = 0
        for item in (wr){
            Calced_Eigenvalues.removeAll()
            for valuex in 0..<(wavefxnNumberData) {
    
                Calced_Eigenvalues.append(vr[valuex + (100 * timer)])
            }
            Calced_Eigenfxns.append(Calced_Eigenvalues)
            timer = timer + 1
        }
        return (returnString)
    }
    
    /// pack2DArray
    /// Converts a 2D array into a linear array in FORTRAN Column Major Format
    ///
    /// - Parameters:
    ///   - arr: 2D array
    ///   - rows: Number of Rows
    ///   - cols: Number of Columns
    /// - Returns: Column Major Linear Array
    func pack2dArray(arr: [[Double]], rows: Int, cols: Int) -> [Double] {
        var resultArray = Array(repeating: 0.0, count: rows*cols)
        for Iy in 0...cols-1 {
            for Ix in 0...rows-1 {
                let index = Iy * rows + Ix
                resultArray[index] = arr[Ix][Iy]
            }
        }
        return resultArray
    }
    
    /// unpack2DArray
    /// Converts a linear array in FORTRAN Column Major Format to a 2D array in Row Major Format
    ///
    /// - Parameters:
    ///   - arr: Column Major Linear Array
    ///   - rows: Number of Rows
    ///   - cols: Number of Columns
    /// - Returns: 2D array
    func unpack2dArray(arr: [Double], rows: Int, cols: Int) -> [[Double]] {
        var resultArray = [[Double]](repeating:[Double](repeating:0.0 ,count:rows), count:cols)
        for Iy in 0...cols-1 {
            for Ix in 0...rows-1 {
                let index = Iy * rows + Ix
                resultArray[Ix][Iy] = arr[index]
            }
        }
        return resultArray
    }
    
    func calcfinalwavefxn(coefficientcount: Int){
        var average = 0.0
        let xcount = mypotentialinstance.Potential.count
        for i in 0..<coefficientcount{
            var summedwavefxn = [Double](repeating: 0.0, count: xcount)
            for j in 0..<coefficientcount{
                    let coefficient = Calced_Eigenfxns[i][j]
                //every time this function loops it takes the coefficient value and multiplies it by all the values on the wave function data, and sum it into the summed wave function value.
                cblas_daxpy(Int32(xcount), coefficient, mywavefxninstance.wavefxnData[i], 1, &summedwavefxn, 1)
            }
            Calced_Wavefxns.append(summedwavefxn)
            //JUST^ NEED TO WORK ON THIS, AND THAT'S IT HOLY SHIT!!!!
        }
       

        
    }
    
    
    
    
    
}
