//
//  MathQuestion.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI
import Foundation

class Problem: Identifiable {
    let type: String
//    let thisProblem: Problem
    
    init(problemType: String) {
        self.type = problemType
    }
    
    // Prints the numerical component to the math question
    // as a string.
    // For example:
    // Sin(pi/6)
    // Used primarily for debugging. Better to call
    // self.printQuestion()
    func print() -> String {
//        return self.thisProblem.print()
        return ""
    }
    
    // Prints possible choices, where choice: 1
    // represents the correct solution. Choices 2, 3, and 4
    // may use whatever methods available to try
    // to produce a "feasible" yet incorrect solution
    func printFakeSol(choice: Int) -> String {
//        return self.thisProblem.printFakeSol(choice: choice)
        return ""
    }
    
    // Prints a string that contains the math question
    func printQuestion() -> String {
        return ""
    }
}


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

class Factoring: Problem {
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
        
        super.init(problemType: "Factoring")
    }
    
    func printSol() -> String {
        var theString = ""
        
        theString += "(\(printPoly(numbers: [self.c1, self.b1])))"
        theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        return theString
    }
    
    override func printQuestion() -> String {
        return "Factor this polynomial."
    }
    
    override func printFakeSol(choice: Int) -> String {
        var theString = ""
        
        switch choice {
        case 1: // correct answer
            theString += "(\(printPoly(numbers: [self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        case 2:
            theString += "(\(printPoly(numbers: [-self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        case 3:
            theString += "(\(printPoly(numbers: [self.c1 + [-1, 1].randomElement()! * Int.random(in: 1..<3), self.b1])))"
            theString += "(\(printPoly(numbers: [self.c2, self.b2])))"
        case 4:
            theString += "(\(printPoly(numbers: [self.c1, self.b1])))"
            theString += "(\(printPoly(numbers: [-self.c2, self.b2])))"
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
    
    override func print() -> String {
        return printPoly(numbers: self.getCoefficients())
        //        return printPoly(numbers: [5, 5, -5, 5, 5, 0, 5, 5, 5, 55, 0, 0, 1, 5, 6 , 7, 8, 9,0 , 225, 6 , 2, 1, 5,6,7 , 8])
    }
}

class Derivative: Problem {
    var coeffNumerator: [Int] = []
    var coeffSol: [Int] = []
    //    var coeffDenominator: [Int] = []
    var indexList = [-5,-4,-3,-2,-1,1,2,3,4,5]
    
    init() {
        for _ in (0..<3) {
            coeffNumerator.append(Int.random(in: -13..<13))
            //            coeffDenominator.append(Int.random(in: -13..<13))
        }
        
        for i in (0..<coeffNumerator.count - 1) {
            coeffSol.append(
                coeffNumerator[i + 1] * (i + 1))
        }
        
        super.init(problemType: "Derivative")
    }
    
    override func print() -> String {
        return printPoly(numbers: coeffNumerator)
    }
    
    func printSol() -> String {
        return printPoly(numbers: coeffSol)
    }
    
    override func printQuestion() -> String {
        return "Find the derivative of this polynomial with respect to x."
    }
    
    override func printFakeSol(choice: Int) -> String {
        var theString = ""
        
        switch choice {
        case 1: // correct answer
            return printPoly(numbers: coeffSol)
        case 2:
            // this is a deep copy
            var fakeCoeffSol: [Int] = coeffSol
//            fakeCoeffSol.insert([-3,-2,-1,1,2,3].randomElement()!, at: 0)
            let randomInt = indexList.randomElement()!
            indexList.remove(at: indexList.firstIndex(of: randomInt)!)
            fakeCoeffSol.insert(randomInt, at: 0)
            theString = printPoly(numbers: fakeCoeffSol)
        case 3:
            var fakeCoeffSol: [Int] = coeffSol
            let randomInt = indexList.randomElement()!
            indexList.remove(at: indexList.firstIndex(of: randomInt)!)
            fakeCoeffSol.append(randomInt)
            theString = printPoly(numbers: fakeCoeffSol)
        case 4:
            var fakeCoeffSol: [Int] = coeffSol
            let randomInt = indexList.randomElement()!
            indexList.remove(at: indexList.firstIndex(of: randomInt)!)
            fakeCoeffSol[Int.random(in: 0..<fakeCoeffSol.count)] += randomInt
//            fakeCoeffSol[Int.random(in: 0..<fakeCoeffSol.count)] += Int.random(in: -3..<4)
            theString = printPoly(numbers: fakeCoeffSol)
        default:
            theString = printPoly(numbers: coeffSol)
        }
        
        return theString
    }
}

class Trig: Problem {
    // This ENTIRE class is handled by
    // PARALLEL arrays, with the exception
    // of the "questionSelect" array,
    // which is shorter.
    // Corresponding array indices are for
    // solutions matching that degree/radian
    // value.
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
        
        super.init(problemType: "Trig")
    }
        
    override func printQuestion() -> String {
        var returnString = "What is the \(trigType) of "
        if (usingRadians) {
            returnString += displayValue + "?"
        } else {
            returnString += "\(displayValue)?"
        }
        return returnString
    }
    
    override func print() -> String {
        return "\(trigType)(\(displayValue))"
    }
    
    func printSol() -> String {
        return self.answer
    }
    
    override func printFakeSol(choice: Int) -> String {
        var returnString: String = ""
        switch choice {
        case 1:
            return self.printSol()
        case 2:
            // picks a random value that is not equal to the solution
            if (trigType == "Tan") {
                returnString = tan[(valueIndex - 1)%tan.count]
            } else {
                // Sin or Cos
                returnString = (trigType == "Sin") ? sines[(valueIndex - 1)%sines.count] : cosines[(valueIndex - 1)%cosines.count]
            }
        case 3:
            // picks a random value not picked in case 2
            if (trigType == "Tan") {
                returnString = tan[(valueIndex + 1)%tan.count]
            } else {
                // Sin or Cos
                returnString = (trigType == "Sin") ? sines[(valueIndex + 1)%sines.count] : cosines[(valueIndex + 1)%cosines.count]
            }
        case 4:
            // Invert sign
            if (self.answer.starts(with: "-")) {
                return String(self.answer.suffix(1))
            } else {
                return "-" + self.answer
            }
        default:
            return self.printSol()
        }
        // Catch-all
        return returnString
    }
}

class Intersection: Problem {
    // Two polynomials, 1 and 2, of the form:
    // bx + c
    let b1: Int = Int.random(in: 1..<14) * [-1, 1].randomElement()!
    let c1: Int = Int.random(in: -20..<21)
    

    let b2: Int = Int.random(in: 1..<14) * [-1, 1].randomElement()!
//    let b1: Int = 7
//    let b2: Int = 7
    let c2: Int = Int.random(in: -20..<21)
    
    init() {
        // To avoid confusing people with the same function
        super.init(problemType: "Intersection")
    }
    
    // Step 1:
    // Set y values equal to each other
    func getXSolution() -> Double? {
        let bsol: Int = b1 - b2
        let csol: Int = c2 - c1
        Swift.print("BSOL: " + String(bsol) + ", CSOL: " + String(csol))
        if bsol != 0 {
            let x: Double = Double(csol) / Double(bsol)
            Swift.print("X: " + String(x))
            return x
        } else {
            return nil // The functions are linearly independent
            // Make sure to print out "no solution" as a choice
        }
    }
    
    func getCoords() -> [Double]? {
        if (self.getXSolution() != nil) {
            return [self.getXSolution()!, Double(b2) * self.getXSolution()! + Double(c2)]
        } else {
            return nil // The functions are linearly independent
        }
    }
    
    // Prints the problem statement without the functions
    override func print() -> String {
        return "Find the coordinates at which these equations intersect.\n"
    }
    
    override func printQuestion() -> String {
        return self.print() + "y = " + printPoly(numbers: [self.c1, self.b1]) + "\n" + "y = " + printPoly(numbers: [self.c2, self.b2])
    }

    // Prints the string that represents the correct seleciton
    func printSol() -> String {
        if (self.getCoords() != nil) {
            let coords: [Double] = self.getCoords()!
            let part1 = String(format: "%.2f", coords[0])
            let part2 = String(format: "%.2f", coords[1])
            return "(" + part1 + ", " + part2 + ")"
        } else {
            return "No solution"
        }
    }
    
    override func printFakeSol(choice: Int) -> String {
        var theString = ""
        
        switch choice {
        case 1: // correct answer
            return self.printSol()
        case 2:
            // Flip the coordinates, x becomes y
            if (self.getCoords() != nil) {
                let coords: [Double] = self.getCoords()!
                let part1 = String(format: "%.2f", coords[0])
                let part2 = String(format: "%.2f", coords[1])
                // Flipped part is below
                return "(" + part2 + ", " + part1 + ")"
            } else {
                // Generate garbage as we are running out of
                // options with there being no solution
                let part1 = String(self.b1) + ".00"
                let part2 = String(self.c1) + ".00"
                return "(" + part1 + ", " + part2 + ")"
            }
        case 3:
            if (self.getCoords() != nil) {
                // This effectively always keeps
                // "No solution" as an option
                // I think we still need to check for nil
                // So that the other cases know when to generate
                // lower quality results
                return "No solution"
            } else {
                // Generate garbage as we are running out of
                // options with there being no solution
                let part1 = String(self.b2) + ".00"
                let part2 = String(self.c2) + ".00"
                // Flipped part is below
                return "(" + part2 + ", " + part1 + ")"
            }
        case 4:
            // Flip signs, keeping x and y the same
            if (self.getCoords() != nil) {
                let coords: [Double] = self.getCoords()!
                let part1 = String(format: "%.2f", -coords[0])
                let part2 = String(format: "%.2f", -coords[1])
                return "(" + part1 + ", " + part2 + ")"
            } else {
                // Generate garbage as we are running out of
                // options with there being no solution
                let part1 = String(-self.b1) + ".00"
                let part2 = String(-self.c2) + ".00"
                return "(" + part1 + ", " + part2 + ")"
            }
        default:
            // Kind of a cop-out if you ask me
            theString = "None of these are correct"
        }
        
        return theString
    }
}

class Integral: Problem {
    var coeffNumerator: [Int] = []
    var coeffSol: [Int] = []
    var indexList = [-5,-4,-3,-2,-1,1,2,3,4,5]
    
    init() {
        for _ in (0..<3) {
            coeffNumerator.append(Int.random(in: -13..<13))
        }
        
        for i in (0..<coeffNumerator.count - 1) {
            coeffSol.append(
                coeffNumerator[i + 1] * (i + 1))
        }
        
        super.init(problemType: "Integral")
    }
    
    override func print() -> String {
        return printPoly(numbers: coeffSol)
    }
    
    func printSol() -> String {
        return printPoly(numbers: coeffNumerator)
    }
    
    override func printQuestion() -> String {
        return "Find the integral of this polynomial with respect to x.\n" + self.print()
    }
}

struct MathQuestion: View {
    var newQuestion = Intersection() // can be Factoring(), Derivative(), Trig(), Intersection(), or Integral()
    
    var body: some View {
//        Text("hello world!")
        Text(newQuestion.printQuestion())
            .monospaced()
        Text(newQuestion.printSol())
            .monospaced()
//        Text(newQuestion.printFakeSol(choice: 1))
//            .monospaced()
//        Text(newQuestion.printFakeSol(choice: 2))
//            .monospaced()
//        Text(newQuestion.printFakeSol(choice: 3))
//            .monospaced()
//        Text(newQuestion.printFakeSol(choice: 4))
//            .monospaced()
    }
}

#Preview {
    MathQuestion()
}
