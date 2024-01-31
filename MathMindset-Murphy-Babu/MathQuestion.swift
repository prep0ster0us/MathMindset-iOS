//
//  MathQuestion.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI
import Foundation


struct polyAns {
    var b1: Int
    var c1: Int
    var b2: Int
    var c2: Int
}

// Has to be in the order: [c, b, a, ... etc]
// Carefully prints a univariate polynomial
// of arbitrary size
// Entirely written by Alex Murphy
func printPoly(numbers: [Int]) -> String {
    var theString = ""
    var theDegree: Int = 0 // equal to the highest order term
    
    var prevNum: Int = 0
    
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
    // ans stores the coefficients of two first order polynomials
    // that are then multiplied to create a second order
    // polynomial
    let ans = polyAns(
        b1: Int.random(in: -5..<5),
        c1: Int.random(in: -12..<12),
        b2: Int.random(in: -3..<3),
        c2: Int.random(in: -6..<6))
    
    // these are the coefficients of a second order polynomial
    // of the form: ax^2 + bx + c
    var a: Int
    var b: Int
    var c: Int
    
    // Initialize the values by cross-multiplying terms
    init() {
        self.a = self.ans.b1 * self.ans.b2
        self.b = self.ans.b1 * self.ans.c2 +
            self.ans.b2 * self.ans.c1
        self.c = self.ans.c1 * self.ans.c2
        
//        self.a = 1
//        self.b = 1
//        self.c = -1
    }
    
    func printSol() -> String {
        var theString = ""
        theString += "(\(self.ans.b1)x + \(self.ans.c1))"
        theString += "(\(self.ans.b2)x + \(self.ans.c2))"
        return theString
    }
    
    func getCoefficients() -> [Int] {
        return [self.c, self.b, self.a]
    }
    
    func print() -> String {
//        return printPoly(numbers: self.getCoefficients())
        return printPoly(numbers: [5, 5, -5, 5, 5, 0, 5, 5, 5, 55, 0, 0])
    }
}




struct MathQuestion: View {
    var newPoly = poly()
    var body: some View {
//        Text(newPoly.print())
        Text(newPoly.print())
    }
}

#Preview {
    MathQuestion()
}
