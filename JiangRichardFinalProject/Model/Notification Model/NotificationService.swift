//
//  NotificationService.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/5.
//

import Foundation
import UserNotifications

class NotificationService {
    let notificationCenter = UNUserNotificationCenter.current()
    var needToAble: [Notification] = []
    var needToDisable: [String] = []
    
    static let sharedInstance = NotificationService()
    
    // merge needToAble & needToDisable and update
    private func merge() {
        // change needToAble to a map: id -> Notification
    }
    
    // helper function send notifications to user
    func scheduleNotification() {
        for notification in needToAble {
            // cnofig content
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default
            content.body = notification.message

            // config time & trigger
            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)

            // config the request
            let request = UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger)

            // add to notification center
            self.notificationCenter.add(request) { error in
                if error != nil {
                    print("Error: " + error.debugDescription)
                }
            }
        }
        needToAble.removeAll()
    }
    
    // helper function remove notifications
    func removeNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: needToDisable)
        needToDisable.removeAll()
    }
}
