//
//  CourseTableViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import UIKit

class CourseTableViewController: UITableViewController {
    
    private var service = Service.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.loadTable = {
            self.tableView.reloadData()
        }
        service.loadCourse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service.loadTable = {
            self.tableView.reloadData()
        }
        service.loadCourse()
        self.tableView.reloadData()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.courses.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseTableCell", for: indexPath) as! CourseTableViewCell
        let course = service.courses[indexPath.row]
        
        // config course title label
        cell.CourseLabel?.layer.masksToBounds = true
        cell.CourseLabel?.layer.cornerRadius = 5
        cell.CourseLabel?.text = course.title
        
        // config course works
        let numOfWorks = course.courseworks.count
        
        if numOfWorks >= 0 {
            cell.stackViewLabel1?.text = ""
            cell.stackViewLabel2?.text = ""
            cell.stackViewLabel3?.text = ""
            cell.stackViewLabel4?.text = ""
        }
        if numOfWorks >= 1 {
            cell.stackViewLabel1?.text = "1. " + course.courseworks[0].title
        }
        if numOfWorks >= 2 {
            cell.stackViewLabel2?.text = "2. " + course.courseworks[1].title
        }
        if numOfWorks >= 3 {
            cell.stackViewLabel3?.text = "3. " + course.courseworks[2].title
        }
        if numOfWorks >= 4 {
            cell.stackViewLabel4?.text = "..."
        }
        
        // config grade label
        let grade = course.grade
        var backgroundColor = UIColor()
        cell.GradeLabel?.layer.masksToBounds = true
        cell.GradeLabel?.layer.cornerRadius = 35
        if grade >= 90 {
            backgroundColor = UIColor(red: 103/255, green: 235/255, blue: 52/255, alpha: 1)
        } else if grade >= 80 {
            backgroundColor = UIColor(red: 214/255, green: 235/255, blue: 52/255, alpha: 1)
        } else if grade >= 70 {
            backgroundColor = UIColor(red: 235/255, green: 177.255, blue: 52/255, alpha: 1)
        } else if grade >= 60 {
            backgroundColor = UIColor(red: 242/255, green: 42/255, blue: 29/255, alpha: 1)
        } else {
            backgroundColor = UIColor(red: 86/255, green: 86/255, blue: 86/255, alpha: 1)
        }
        cell.GradeLabel?.backgroundColor = backgroundColor
        cell.GradeLabel?.text = String(course.grade)

        // config edit button
        cell.editAction = { sender in
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    // set height of cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    // prepare for the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pre-modify target view controller
        let modifyCourseViewController = segue.destination as! ModifyCourseViewController
        
        if segue.identifier == "EditCourseSegue" {
            let row: Int = (tableView.indexPathForSelectedRow?.row)!
            modifyCourseViewController.navTitle = "Edit the Course"
            service.courseIndex = row
        } else if segue.identifier == "AddCourseSegue" {
            modifyCourseViewController.navTitle = "Add a Course"
            service.addEmptyCourseToDB()
            modifyCourseViewController.onCancel = {
                self.service.deleteCourse()
//                self.service.courseIndex = self.service.courses.count - 1
            }
        }
    }
    
    
    // edit button tapped
    @IBAction func editButtonDidTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
        } else {
            tableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    // add trailing swipe action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // for delete
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            // delete course
            self.service.courseIndex = indexPath.row
            self.service.deleteCourse()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        // for archive
        let archive = UIContextualAction(style: .normal, title: "Archive") { (action, view, completionHandler) in
            // archive course
            self.service.courseIndex = indexPath.row
            self.service.archiveCourse()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        archive.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, archive])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

}
