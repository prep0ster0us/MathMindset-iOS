
//
//  Notifcations.swift
//  MathMindset-Murphy-Babu
//
//  Created by Alex Murphy on 4/2/24.
//
// Adapted from below:
// https://www.youtube.com/watch?v=mG9BVAs8AIo
//
// Also enabled foreground notifications based on:
// https://developer.apple.com/documentation/usernotifications/handling-notifications-and-notification-related-actions

import Foundation
import UserNotifications

// Note: Does not show if the app is in the
// foreground when the notification triggers
func createNotification() async {
    let center = UNUserNotificationCenter.current()
    do {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    } catch {
        // Handle the error here.
        print("User declined notifications")
    }
    
    let content = UNMutableNotificationContent()
    content.title = "Problem of the Day"
    content.body = "Every day at 9am"
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "POTD" // Used to distinguish from others
    
    // Currently set to 13:00 in the user's timezone
    // (1:00pm)
    var dateComponents = DateComponents()
    dateComponents.timeZone = TimeZone.autoupdatingCurrent
    dateComponents.hour = 9 // this is in a 24 hour format i.e. 21 hours = 9pm
    dateComponents.minute = 0
//    print(dateComponents.description) // debug trigger time
    
    // Create the trigger as a repeating event.
    let trigger = UNCalendarNotificationTrigger(
             dateMatching: dateComponents, repeats: true)
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()

    do {
        try await notificationCenter.add(request)
        print("SUCCESSFULLY ADDED NOTIFICATION")
    } catch {
        // Handle errors that may occur during add.
        print("NOTIFICATION DID NOT FIRE")
    }
}
