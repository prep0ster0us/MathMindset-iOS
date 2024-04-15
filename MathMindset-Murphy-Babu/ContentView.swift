//
//  ContentView.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI

class AppVariables: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var streak: Int = 4
    @Published var primes: Int = 45
    @Published var probOfDaySolved: Bool = false
    @Published var timeLeft: String = "10:09:45"
//    @Published var timeLeft: Int = 0
    @Published var screenWidth: CGFloat = UIScreen.main.bounds.width
    @Published var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    func setStreak(newVal: Int) {
        streak = newVal
    }
    // Used for quiz page
    @Published var selectedButton: Int = -1
}

struct ContentView: View {
    var body: some View {
//        BottomBar(
//            AnyView(HomeView()),
//            AnyView(Leaderboards()),
//            AnyView(Profile())
//        )
//        .environmentObject(AppVariables())
//        GenerateProblems()
        SplashScreenView()
    }
}

#Preview {
    ContentView()
}
