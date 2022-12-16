//
//  CourseTableViewCell.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/2.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var CourseLabel: UILabel!
    @IBOutlet weak var GradeLabel: UILabel!
    
    @IBOutlet weak var stackViewLabel1: UILabel!
    @IBOutlet weak var stackViewLabel2: UILabel!
    @IBOutlet weak var stackViewLabel3: UILabel!
    @IBOutlet weak var stackViewLabel4: UILabel!
    
    var editAction: ((Any) -> Void)?
    
    
    @IBAction func EditDidTapped(_ sender: UIButton) {
        self.editAction?(sender)
        
    }
    
}
