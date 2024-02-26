//
//  MathQuestion.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI
import Foundation

var primes: [Int] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29] //, 31, 37, 41]
let supers: [String] = [
    "⁰",
    "¹",
    "²",
    "³",
    "⁴",
    "⁵",
    "⁶",
    "⁷",
    "⁸",
    "⁹"]

// Has to be in this order: [c, b, a, ... etc]
// i.e. smallest digit is at index 0
// Carefully prints a univariate polynomial
// of arbitrary size
// Entirely written by Alex Murphy
func printPoly(numbers: [Int]) -> String {
    var theString: String = ""
    var theDegree: Int = 0 // equal to the highest order term
    
    var prevNum: Int = 0
    
    var stringTheDegree: String = "" // Gets updated later to 2 or above
    
    numbers.forEach { number in
        if prevNum > 0 {
            theString = "+" + theString
        }
        if number != 0 {
            if abs(number) == 1 {
                if theDegree == 0 {
                    // Most trivial case: c = 1
                    theString = String(number)
                } else if theDegree == 1 {
                    // b
                    if number > 0 {
                        theString = "x" + theString
                    } else {
                        theString = "-x" + theString
                    }
                } else {
                    // theDegree > 1
                    if number > 0 {
                        theString = "x\(stringTheDegree)" + theString
                    } else {
                        theString = "-x\(stringTheDegree)" + theString
                    }
                }
            } else {
                if theDegree == 0 {
                    // Most trivial case: c = a constant
                    theString = String(number)
                } else if theDegree == 1 {
                    // b
                    theString = "\(number)x" + theString
                } else {
                    // theDegree > 1
                    theString = "\(number)x\(stringTheDegree) " + theString
                }
            }
        }
        prevNum = number
        theDegree += 1
        stringTheDegree = ""
        for character in String(theDegree) {
            stringTheDegree += String(supers[Int(String(character))!])
        }
//        stringTheDegree = String(supers[theDegree])
    }
    // This is WAY easier than formatting at the same time
    theString.replace("+", with: " + ")
    theString.replace("-", with: " - ")
    // Catch leading "-" signs
    if theString.starts(with: " -") {
        theString = "-" + theString.suffix(theString.count - 3)
    } else if theString.starts(with: " +") {
        theString = "" + theString.suffix(theString.count - 3)
    }
    
    return theString
}


class poly {
    // These are the coefficients of two
    // first order polynomials that are multiplied
    // to obtain the non-factored solution
    // b1 and b2 are generated as random elements
    // from the above Int arrays.
    // c1 and c2 are random primes of small size
    var b1: Int
    var c1: Int
    var b2: Int
    var c2: Int
    
    
    // these are the coefficients of a second order polynomial
    // of the form: ax^2 + bx + c
    var a: Int
    var b: Int
    var c: Int
    
    
    init() {
        let b1Selectable: [Int] = [-1, 0, 1]
        let b2Selectable: [Int] = [-3,
                                    -2,
                                    -1,
                                    1,
                                    2,
                                    3]
        self.b1 = b1Selectable.randomElement()!
        self.c1 = primes.randomElement()!
        self.b2 = b2Selectable.randomElement()!
        self.c2 = primes.randomElement()!
        
        
        // Fix the factored solution so that it
        // is not actually factorable still.
        // For b1 and c1 it is currently not necessary
        //        if abs(self.b1) > 1 {
        //            while self.c1 % self.b1 == 0 {
        //                self.c1 += 1
        //            }
        //        }
        if abs(self.b2) > 1 {
            while self.c2 % self.b2 == 0 {
                self.c2 += 1
            }
        }
        
        // Initialize the values by cross-multiplying
        // terms from the factored solution
        self.a = self.b1 * self.b2
        self.b = self.b1 * self.c2 +
        self.b2 * self.c1
        self.c = self.c1 * self.c2
    }
    
    func printSol() -> String {
        var theString = ""
        
        theString += "(\(printPoly(numbers: [self.c1, self.b1])))"
        theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        return theString
    }
    
    func printFakeSol(choice: Int) -> String {
        var theString = ""
        
        switch choice {
        case 1:
            theString += "(\(printPoly(numbers: [self.c1, self.b2])))"
            theString += "(\(printPoly(numbers: [self.c2, self.b1])))"
        case 2:
            theString += "(\(printPoly(numbers: [-self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        case 3:
            theString += "(\(printPoly(numbers: [-self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [-self.c2, self.b2])))"
        case 4:
            theString += "(\(printPoly(numbers: [self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [-self.c2, self.b2])))"
        case 5:
            theString += "(\(printPoly(numbers: [self.c1, -self.b1])))"
            theString += "(\(printPoly(numbers: [self.c2, -self.b2])))"
        default:
            theString = self.printSol()
        }
        
        return theString
    }
    
    func getSol() -> [[Int]] {
        return [[self.b1, self.b2], [self.c1, self.c2]]
    }
    
    func getCoefficients() -> [Int] {
        return [self.c, self.b, self.a]
    }
    
    func print() -> String {
        return printPoly(numbers: self.getCoefficients())
//        return printPoly(numbers: [5, 5, -5, 5, 5, 0, 5, 5, 5, 55, 0, 0, 1, 5, 6 , 7, 8, 9,0 , 225, 6 , 2, 1, 5,6,7 , 8])
    }
}




struct MathQuestion: View {
    var newPoly = poly()
    var body: some View {
        Text(newPoly.print())
            .monospaced()
        Text(newPoly.printSol())
            .monospaced()
    }
}

#Preview {
    MathQuestion()
}
