//
//  ContentView.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI

class AppVariables: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var streak: Int = 0
    @Published var primes: Int = 45
    @Published var probOfDaySolved: Bool = true
    @Published var timeLeft: Int = 0
    @Published var screenWidth: CGFloat = UIScreen.main.bounds.width
    @Published var screenHeight: CGFloat = UIScreen.main.bounds.height
}

struct ContentView: View {
    var body: some View {
        BottomBar(
            AnyView(Home()),
            AnyView(Leaderboards()),
            AnyView(Profile())
        )
        .environmentObject(AppVariables())
    }
}

#Preview {
    ContentView()
}
