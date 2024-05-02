//
//  MultipleChoice.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 2/5/24.
//

import SwiftUI
import ConfettiSwiftUI

struct MultipleChoice: View { // TODO: Rename this to ProblemPage
    @State private var a: String = ""
    @State private var b: String = ""
    @State private var c: String = ""

    @State private var selections: [Int] = [1, 2, 3, 4].shuffled()
    // Value of selections when choice: selections[i] == 1
    @State private var correctSelection: Int = 1
    // State variable for containing the .tag value selected by
    // the user
    @State private var selection: Int = 1
    // Therefore, when selections[selection - 1] == 1, the
    // user has selected the correct answer
    
    // required state variable for the confetti package
    @State private var confettiCounter: Int = 0

    private var thisProblem: Problem
    
    init(problemType: String) {
        switch(problemType) {
        case "Derivative":
            self.thisProblem = Derivative()
        case "Trig":
            self.thisProblem = Trig()
        case "Factoring":
            self.thisProblem = Factoring()
        case "Intersection":
            self.thisProblem = Intersection()
        case "Integral":
            self.thisProblem = Integral()
        default:
            self.thisProblem = Factoring()
        }
    }
    
    var body: some View {
        VStack {
            Text(thisProblem.printQuestion())
                .padding(20)
            Text(thisProblem.print())
                .monospaced()
                .padding(20)
            VStack(spacing: 20) {
                Picker(selection: $selection, label: Text("Favorite Color")) {
                    Text(thisProblem.printFakeSol(choice: selections[0])).tag(1)
                    Text(thisProblem.printFakeSol(choice: selections[1])).tag(2)
                    Text(thisProblem.printFakeSol(choice: selections[2])).tag(3)
                    Text(thisProblem.printFakeSol(choice: selections[3])).tag(4)
                }
//                .pickerStyle(.radioGroup)
                Button("Submit", action: handleResponse)
                    .buttonStyle(.bordered)
                    .confettiCannon(counter: $confettiCounter)
            }.padding(20)
        }
    }
    
    func handleResponse() {
        if (selections[selection - 1] == correctSelection) {
            confettiCounter += 1
        }
    }
}

#Preview {
    MultipleChoice(problemType: "Trig")
}
