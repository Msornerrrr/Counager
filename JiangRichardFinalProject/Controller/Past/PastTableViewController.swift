//
//  PastTableViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/11/19.
//

import UIKit

class PastTableViewController: UITableViewController {
    
    private var service = Service.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        service.loadTable = {
            self.tableView.reloadData()
        }
        service.loadPastCourse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service.loadTable = {
            self.tableView.reloadData()
        }
        service.loadPastCourse()
        self.tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.pastCourses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastCourseCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let course = service.pastCourses[indexPath.row]
        
        config.text = course.title
        config.secondaryText = String(course.grade)
        
        cell.contentConfiguration = config
        return cell
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
            // delete past course
            self.service.pastCourseIndex = indexPath.row
            self.service.deletePastCourse()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        // for put back
        let putBack = UIContextualAction(style: .normal, title: "Put Back") { (action, view, completionHandler) in
            // put back past course
            self.service.pastCourseIndex = indexPath.row
            self.service.putBackCourse()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        putBack.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, putBack])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

}
