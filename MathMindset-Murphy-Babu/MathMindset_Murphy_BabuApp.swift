//
//  MathMindset_Murphy_BabuApp.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 1/30/24.
//

import SwiftUI
import Firebase
import GoogleSignIn

//class AppDelegate: NSObject, UIApplicationDelegate {
// Below is changed for notifications
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
            print("Foreground notification!")
            // Play a sound to let the user know about the invitation.
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

        }
    }
}

