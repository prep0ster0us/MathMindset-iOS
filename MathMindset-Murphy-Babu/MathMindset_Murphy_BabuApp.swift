//
//  MathMindset_Murphy_BabuApp.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI
import Firebase
import GoogleSignIn
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MathMindset_Murphy_BabuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    
//    init() {
//        FirebaseApp.configure()
//    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
//        .onAppear {
//            if UserDefaults.standard.string(forKey: "appTheme") == nil {
//                UserDefaults.standard.set("light", forKey: "appTheme")
//            } else {
//                appTheme = colorScheme
//            }
//        }
    }
}

class SettingsStore: ObservableObject {
    @Published var themeActivated: Bool {
        didSet {
            UserDefaults.standard.set(themeActivated, forKey: "isDarkMode")
        }
    }
    
    init() {
        themeActivated = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}


