//
//  Home.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject private var app: AppVariables

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "flame")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.red)
                Text("\(app.streak)")
                Spacer()
                Image(systemName: "sparkles")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.yellow)
                Text("\(app.primes)")
            }
            .padding(50)
            
            VStack {
                Text("Problem of the Day")
                    // TODO: Find our own smallcaps font
                    .font(Font.system(.title).smallCaps())
                    .underline()
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 25, trailing: 0))
                Image(systemName: "lightbulb.max")
                    .resizable()
                    .frame(width: 80, height: 100)
                Button(action: ProblemOfDay) {
                    Text(($app.probOfDaySolved.wrappedValue) ? "Solve" : "\($app.timeLeft.wrappedValue)")
                }
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(($app.probOfDaySolved.wrappedValue) ? Color(red: 0, green: 0.8, blue: 1) : Color(red: 0.7, green: 0.7, blue: 0.7))
                        .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                        .shadow(radius: 5)
                    .frame(width: 175, height: 50)
                )
                .foregroundColor(.black)
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.85, green: 0.95, blue: 1))
                    .shadow(radius: 5)
            .frame(width: 285, height: 285))
            
            Spacer()
            
        }.onAppear(
            // TODO: Update timeleft string
//            $app.timeLeft
        )
    }
    
    func ProblemOfDay() {
        // does nothing right nowc
        // TODO: needs to generate a MultipleChoice question
        
    }
}

#Preview {
    Home()
        .environmentObject(AppVariables())
}
