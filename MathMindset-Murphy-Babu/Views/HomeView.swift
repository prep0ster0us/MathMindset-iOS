//
//  Home.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppVariables
    
    var titles: [String] = ["Factoring",
                            "Derivative",
                            "Trig"]
    
    // TODO: static question for now, make this dynamic by fetching from db
    let problem = Derivative()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(app.streak>0 ? "streakActive" : "streakInactive")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(app.streak)")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Image(app.primes>0 ? "primes" : "primesEmpty")
                        .resizable()
                        .frame(width: 32, height: 32)
                    Text("\(app.primes)")
                        .font(.system(size: 20, weight: .bold))
                }
                .padding()
                .padding(.top, 50)
                
                VStack {
                    Text("Problem of the Day")
                    // TODO: Find our own smallcaps font
                        .font(Font.system(.title).smallCaps())
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.textTint))
                        .underline()
                        .padding(.bottom, 12)
                    Image(app.probOfDaySolved ? "potdInactive" : "potdActive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                    NavigationLink(destination: ProblemOfDay(
                        question    : problem.printQuestion()+"\n"+problem.print(),
                        choices     : [problem.printFakeSol(choice: 0),
                                       problem.printFakeSol(choice: 1),
                                       problem.printFakeSol(choice: 2),
                                       problem.printFakeSol(choice: 3)]
                    ).environmentObject(AppVariables())) {
                            Text(($app.probOfDaySolved.wrappedValue) ? "Solve" : "\($app.timeLeft.wrappedValue)")
                                .font(.title2)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(($app.probOfDaySolved.wrappedValue) ? Color(red: 0, green: 0.8, blue: 1) : Color(red: 0.7, green: 0.7, blue: 0.7))
                                        .strokeBorder(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                                        .shadow(radius: 5)
                                        .frame(width: 175, height: 50)
                                )
                                .foregroundColor(.black)
                                .padding(.top, 24)
                    }
                }.background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.85, green: 0.95, blue: 1))
                        .shadow(radius: 5)
                        .frame(width: 285, height: 275)
                )
                .padding(.top, 36)
                .padding(.bottom, 20)
                
                ScrollView{
                    VStack(alignment: .leading) {
                        ForEach(titles, id: \.self) { title in
                            TopicCard(name: title, image: title, completed: 1)
                                .frame(width: $app.screenWidth.wrappedValue)
                        }.padding(.top, 10)
                    }
                }.padding(.top, 30)
                
                Spacer()
                
            }.ignoresSafeArea(.all)
                .onAppear(
                    // TODO: Update timeleft string
                    //            $app.timeLeft
                )
        }.navigationBarBackButtonHidden(true)
    }
    
//    func ProblemOfDay() {
//        // does nothing right nowc
//        // TODO: needs to generate a MultipleChoice question
//        
//    }
}

#Preview {
    HomeView()
        .environmentObject(AppVariables())
}
