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

class Derivative {
    var coeffNumerator: [Int] = []
    var coeffSol: [Int] = []
//    var coeffDenominator: [Int] = []
    init() {
        for _ in (0..<5) {
            coeffNumerator.append(Int.random(in: -13..<13))
//            coeffDenominator.append(Int.random(in: -13..<13))
        }
        
        for i in (0..<coeffNumerator.count - 1) {
            coeffSol.append(
                coeffNumerator[i + 1] * (i + 1))
        }
    }
    
    func print() -> String {
        return printPoly(numbers: coeffNumerator)
    }

    func printSol() -> String {
        return printPoly(numbers: coeffSol)
    }
}

class Trig {
    var Question: String = ""
    let questionSelect: [String] =
    ["Sin",
     "Cos",
     "Tan"]
    // TODO: Add support for more functions
    //         "Csc",
    //         "Sec",
    //         "Cot"]
    
    
    let questionValueDegrees: [Int] =
    [0,
     30,
     45,
     60,
     90,
     120,
     135,
     150,
     180]
    
    let questionValueRadians: [String] =
    ["0",
     "π/6",
     "π/4",
     "π/3",
     "π/2",
     "2π/3",
     "3π/4",
     "5π/6",
     "π"]
    
    let usingRadians: Bool = Bool.random()
    
    let sines: [String] =
    ["0",
     "1/2",
     "sqrt(2)/2",
     "sqrt(3)/2",
     "1",
     "sqrt(3)/2",
     "sqrt(2)/2",
     "1/2",
     "0"]
    
    let cosines: [String] =
    ["1",
     "sqrt(3)/2",
     "sqrt(2)/2",
     "1/2",
     "0",
     "-1/2",
     "-sqrt(2)/2",
     "sqrt(3)/2",
     "-1"]
    
    let tan: [String] =
    ["0",
     "sqrt(3)/3",
     "1",
     "sqrt(3)",
     "undefined",
     "-sqrt(3)",
     "-1",
     "-sqrt(3)/3",
     "0"]
    
    // This index will be used to access
    // all corresponding hardcoded values
    var valueIndex: Int
    var displayValue: String
    var answer: String
    var trigType: String
    init() {
        valueIndex = Int.random(in:0..<sines.count)
        
        if (usingRadians) {
            displayValue = questionValueRadians[valueIndex]
        } else {
            displayValue = String(questionValueDegrees[valueIndex]) + "°"
        }
        trigType = questionSelect.randomElement()!
        
        switch(trigType) {
        case "Sin":
            answer = sines[valueIndex]
        case "Cos":
            answer = cosines[valueIndex]
        default:
            answer = tan[valueIndex]
        }
    }
        
    func printQuestion() -> String {
        var returnString = "What is the \(trigType) of "
        if (usingRadians) {
            returnString += displayValue + "?"
        } else {
            returnString += "\(displayValue)?"
        }
        return returnString
    }
    
    func print() -> String {
        return "\(trigType)(\(displayValue))"
    }
    
    func printSol() -> String {
        return self.answer
    }
}



struct MathQuestion: View {
//    var newQuestion = poly()
//    var newQuestion = Derivative()
    var newQuestion = Trig()
    var body: some View {
        Text(newQuestion.print())
            .monospaced()
        Text(newQuestion.printSol())
            .monospaced()
    }
}

#Preview {
    MathQuestion()
}
