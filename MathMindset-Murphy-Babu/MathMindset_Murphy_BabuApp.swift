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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        return true
    }
    
    // foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.categoryIdentifier == "POTD" {
            print("Foreground POTD notification!")
            // Play a sound and make a banner to let the user know about the invitation.
            completionHandler([.alert, .sound])
            return
        }


        // Don't alert the user for other types.
        completionHandler(UNNotificationPresentationOptions(rawValue: 0))
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


