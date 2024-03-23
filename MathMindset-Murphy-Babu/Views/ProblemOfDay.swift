//
//  ProblemOfDay.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

import SwiftUI

struct ProblemOfDay: View {
    let question    : String
    let choices     : [String]
    
    @EnvironmentObject private var app: AppVariables
    @State private var isPressed: CGFloat = 0
    
    var body: some View {
        VStack {
            
            // Problem Number header
            Text("Problem of the day")
                .font(.system(size: 32))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .underline()
                .padding(.top, 32)
                .padding(.bottom, 24)
            
            // Problem Statement
            let problemStatement = question.split(whereSeparator: \.isNewline)
            
            Text(problemStatement[0])
                .font(.title2)
                .fontWeight(.semibold)
                .shadow(radius: 20)
                
                .animation(.easeIn, value: 0.8)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(problemStatement[1])
                .font(.title)
                .fontWeight(.bold)
                .shadow(radius: 20)
                .padding(24)
                .animation(.easeIn, value: 0.8)
                .padding(.bottom, 16)
            
            // VERTICAL Layout for choices
            //            VStack(spacing: 30) {
            //                HStack {
            //                    ProblemOption(choice: choices[0])
            //                    Spacer()
            //                    ProblemOption(choice: choices[1])
            //                }.padding(.horizontal, 40)
            //                HStack {
            //                    ProblemOption(choice: choices[2])
            //                    Spacer()
            //                    ProblemOption(choice: choices[3])
            //                }.padding(.horizontal, 40)
            //            }
            
            // Horizontal Layout for choices
            VStack(spacing: 28) {
                ProblemOption(choices, $isPressed, 0)
                ProblemOption(choices, $isPressed, 1)
                ProblemOption(choices, $isPressed, 2)
                ProblemOption(choices, $isPressed, 3)
            }.padding(.horizontal, 40)
            
            Spacer()
            
            // Submit answer
            SubmitButton(isPressed, isPOTD: true).environmentObject(AppVariables())
                .padding()
        }.background(
            LinearGradient(colors: [Color(.systemTeal).opacity(0.4), Color(.systemBlue).opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(.ultraThinMaterial)
                .ignoresSafeArea()                  // to cover the entire screen
        )
    }
}

#Preview {
    ProblemOfDay(
        question: "This is a sample question\nThis is sample equation",
        choices : ["Circle", "Triangle", "Square", "Polygon"]
    ).environmentObject(AppVariables())
}
