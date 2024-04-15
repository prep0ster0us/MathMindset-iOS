//
//  BottomBar.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 3/18/24.
//

import SwiftUI

struct BottomBar: View {
    @EnvironmentObject private var app: AppVariables
    let Home: AnyView
    let Leaderboards: AnyView
    let Profile: AnyView
    
    init(
        _ Home : AnyView,
        _ Leaderboards : AnyView,
        _ Profile : AnyView
    ){
        self.Home = Home
        self.Leaderboards = Leaderboards
        self.Profile = Profile
        
        // TODO: Below does nothing?
        //        UITabBar.appearance().barTintColor = UIColor(.yellow)
        UITabBar.appearance().backgroundColor = UIColor(Color(red: 0, green: 0.8, blue: 1))
        UITabBar.appearance().unselectedItemTintColor = UIColor(.gray)
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $app.selectedTab){
                Home
                    .tabItem{
                         Image($app.selectedTab.wrappedValue == 0 ? "homeActive" : "homeInactive")
                            .foregroundStyle(.iconTint)
                         Text("Home")
                            .foregroundStyle(.textTint)
                    }
                    .tag(0)
                Leaderboards
                    .tabItem{
                        Image($app.selectedTab.wrappedValue == 1 ? "LeaderboardActive" : "LeaderboardInactive")
                            .foregroundStyle(.iconTint)
                        Text("Leaderboard")
                            .foregroundStyle(.textTint)
                    }
                    .tag(1)
                Profile
                    .tabItem {
                         Image($app.selectedTab.wrappedValue == 2 ? "profileActive" : "profileInactive")
                            .foregroundStyle(.iconTint)
                        Text("Profile")
                            .foregroundStyle(.textTint)
                        
                    }
                    .tag(2)
            }.tint(.black)
                .ignoresSafeArea(.all)
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    BottomBar(
        AnyView(HomeView()),
        AnyView(Leaderboards()),
        AnyView(Profile())
    )
    .environmentObject(AppVariables())
}
