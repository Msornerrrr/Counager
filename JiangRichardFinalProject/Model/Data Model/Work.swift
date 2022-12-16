//
//  Task.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import Foundation
import FirebaseFirestore

class Work {
    var title: String
    var due: Date
    var isNotify: Bool
    var notifyId: String?
    
    init(title: String, due: Date, isNotify: Bool, notifyId: String?) {
        self.title = title
        self.due = due
        self.isNotify = isNotify
        self.notifyId = notifyId
    }
}
