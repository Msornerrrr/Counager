//
//  Notification.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/5.
//

import Foundation

class Notification {
    var identifier: String
    var title: String
    var message: String
    var date: Date
    
    init(identifier: String, title: String, message: String, date: Date) {
        self.identifier = identifier
        self.title = title
        self.message = message
        self.date = date
    }
}
