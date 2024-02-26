//
//  Factoring.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 2/5/24.
//

import SwiftUI



struct Factoring: View {
    @State private var a: String = ""
    @State private var b: String = ""
    @State private var c: String = ""

    @State private var selection: Int = 1
    
    var thisPoly = poly() // TODO: use @ somehow?
    

    var body: some View {
        VStack {
            Text("Factor this polynomial!")
                .padding(20)
            Text(thisPoly.print())
                .monospaced()
                .padding(20)
            VStack(spacing: 20) {
                Picker(selection: $selection, label: Text("Favorite Color")) {
                    Text(thisPoly.printSol()).tag(1)
                    Text(thisPoly.printFakeSol(choice: 2)).tag(2)
                    Text(thisPoly.printFakeSol(choice: 3)).tag(3)
                    Text(thisPoly.printFakeSol(choice: 4)).tag(4)
                }
//                .pickerStyle(.radioGroup)
                Button("Submit", action: doNothing)
                    .buttonStyle(.bordered)
            }.padding(20)
        }
    }
}

func doNothing() {
    
}
#Preview {
    Factoring()
}
