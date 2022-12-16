//
//  Class.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import Foundation
import FirebaseFirestore

class Course {
    var id: String
    var title: String
    var courseworks: [Work]
    var grade: Int
    
    init(id: String, title: String, courseworks: [Work], grade: Int) {
        self.id = id
        self.title = title
        self.courseworks = courseworks
        self.grade = grade
    }
    
}
