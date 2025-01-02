//
//  NotificationManager.swift
//  Workk
//
//  Created by Krzysztof Kogut on 21/11/2024.
//

import UserNotifications

class NotificationManager {
    private let dailyNotificationIndentifier = "daily_notification"
    private let weeklyNotificationIndentifier = "weekly_notification"

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            } else {
                print("Permission granted: \(granted)")
            }
        }
    }

    func scheduleDailyNotification(at time: Date) {
        // Extract hour and minute from the selected time
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        let content = UNMutableNotificationContent()
        content.title = "daily_notification_title".localized
        content.body = "daily_notification_body".localized
        content.sound = .default

        // Create a trigger for the selected time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a notification request
        let request = UNNotificationRequest(
            identifier: dailyNotificationIndentifier,
            content: content,
            trigger: trigger)

        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(hour):\(minute)")
            }
        }
    }

    func scheduleDailyNotification(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "daily_notification_title".localized
        content.body = "daily_notification_body".localized
        content.sound = .default

        // Configure the trigger for the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour // Set the hour (24-hour format)
        dateComponents.minute = minute // Set the minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the notification request
        let request = UNNotificationRequest(
            identifier: dailyNotificationIndentifier,
            content: content,
            trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            } else {
                print("Daily notification scheduled successfully at \(hour):\(minute)")
            }
        }
    }

    func scheduleWeeklyNotification(on weekday: Int, at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "weekly_notification_title".localized
        content.body = "weekly_notification_body".localized
        content.sound = .default

        // Set up the trigger for a specific weekday and time
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday // 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        dateComponents.hour = hour // 24-hour format
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the notification request
        let request = UNNotificationRequest(identifier: weeklyNotificationIndentifier, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly notification: \(error)")
            } else {
                print("Weekly notification scheduled for weekday \(weekday) at \(hour):\(minute).")
            }
        }
    }

    func cancelDailyNotification() {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(
                withIdentifiers: [dailyNotificationIndentifier, weeklyNotificationIndentifier])
        
        print("Notification canceled.")
    }
}
