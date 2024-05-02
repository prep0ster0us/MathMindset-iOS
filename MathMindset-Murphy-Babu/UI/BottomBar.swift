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
    }
    @State private var tabSelection = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $tabSelection) {
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
                            .font(.system(size: 16, weight: .semibold))
                        
                    }
                    .tag(2)
            }.tint(.textTint)
                .ignoresSafeArea(.all)
                .overlay(alignment: .bottom) {
                    FloatingBottomBar(selectedTab: $tabSelection)
                        .offset(y: 12)
                }
                .toolbarBackground(.hidden, for: .tabBar)
                .onAppear {
                    UITabBar.appearance().backgroundColor = .clear
                    UITabBar.appearance().unselectedItemTintColor = .darkGray
                }
        }.navigationBarBackButtonHidden(true)
    }
}

// design idea from: https://www.youtube.com/watch?v=Yg3cmpKNieU
struct FloatingBottomBar: View {
    @Binding var selectedTab: Int
    
    let tabBarItems: [(title: String, activeImg: String, inactiveImg: String)] = [
        ("Home", "homeActive", "homeInactive"),
        ("Leaderboard", "LeaderboardActive", "LeaderboardInactive"),
        ("Profile", "profileActive", "profileInactive")
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundColor(Color(.systemGray5))
            HStack  {
                ForEach(0..<3) { index in
                    Spacer()
                    Button {
                        withAnimation(.none) { selectedTab = index }
                    } label: {
                        VStack {
                            if index == selectedTab {
                                Image(tabBarItems[index].activeImg)
                            } else {
                                if colorScheme == .dark {
                                    Image(tabBarItems[index].inactiveImg)
                                        .renderingMode(.template)   // to render 'inactive' mode image in white, for dark mode
                                        .foregroundStyle(.iconTint)
                                } else {
                                    Image(tabBarItems[index].inactiveImg)
                                }
                            }
                            Text(tabBarItems[index].title)
                                .foregroundStyle(index == selectedTab 
                                                 ? .textTint
                                                 : (colorScheme == .dark ? .textTint.opacity(0.8) : Color(.darkGray))
                                )
                                .font(.caption)
                                .fontWeight(index == selectedTab ? .bold : .medium)
                        }
                    }.padding(.horizontal)
                    Spacer()
                }
            }
        }.frame(width: UIScreen.main.bounds.width-24, height: 68)
    }
}

#Preview {
//    BottomBar(
//        AnyView(HomeView()),
//        AnyView(Leaderboards()),
//        AnyView(Profile())
//    )
//    .environmentObject(AppVariables())
    FloatingBottomBar(selectedTab: .constant(0))
    .previewLayout(.sizeThatFits)
    .padding()
}
