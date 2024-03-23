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
        TabView(selection: $app.selectedTab){
            Home
                .tabItem{
                    Image(systemName: "house.fill")
                    //                    Text("Cart")
                }
                .tag(0)
            Leaderboards
                .tabItem{
                    // TODO: Issue is that no tint can be added
                    // to a png
                    ($app.selectedTab.wrappedValue == 1) ?
                    Image("Leaderboards") :
                    Image("Leaderboards2")
                }
                .tag(1)
            Profile
                .tabItem {
                    Image(systemName: "person")
                }
                .tag(2)
        }
        .tint(.yellow)
    }
}

#Preview {
    BottomBar(
        AnyView(Home()),
        AnyView(Leaderboards()),
        AnyView(Profile())
    )
    .environmentObject(AppVariables())
}
