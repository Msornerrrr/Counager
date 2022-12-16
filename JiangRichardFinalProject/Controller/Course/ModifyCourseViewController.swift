//
//  EditCourseViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/3.
//

import UIKit

class ModifyCourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var service = Service.sharedInstance
    var navTitle: String = "Modify the Course"
    let notificationService = NotificationService.sharedInstance
    var onCancel: (() -> Void)?
    
    @IBOutlet weak var modifyNavigationItem: UINavigationItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var workTabelView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss keyboard when tapped around
        self.hideKeyboardWhenTappedAround()
        
        // tell service to load tableview
        service.loadTable = {
            self.workTabelView.reloadData()
        }
        
        // set navigation title
        modifyNavigationItem.title = navTitle
        
        // optionally set course title
        titleTextField.text = service.getCourse()?.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workTabelView.reloadData()
    }
    
    
    // how many cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.getCourse()?.courseworks.count ?? 0
    }
    
    // config the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkCellForCourse", for: indexPath)
        var config = cell.defaultContentConfiguration()
        
        config.text = service.getCourse()?.courseworks[indexPath.row].title
        config.secondaryText = service.getCourse()?.courseworks[indexPath.row].due.formatted()
        cell.contentConfiguration = config
        
        return cell
    }
    
    // edit the table
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            service.deleteWork(workIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // if edit button tapped
    @IBAction func editButtonDidTapped(_ sender: UIButton) {
        if workTabelView.isEditing {
            workTabelView.isEditing = false
            sender.setTitle("Edit", for: .normal)
        } else {
            workTabelView.isEditing = true
            sender.setTitle("Done", for: .highlighted)
        }
    }
    
    // if cancel button tapped
    @IBAction func cancelButtonDidTapped(_ sender: UIBarButtonItem) {
        onCancel?()
        dismiss(animated: true)
    }
    
    // if save button tapped
    @IBAction func saveButtonDidTapped(_ sender: UIBarButtonItem) {
        // update notification service
        notificationService.scheduleNotification()
        notificationService.removeNotification()
        
        // update service
        service.updateTitle(title: titleTextField.text!)
        service.saveCourseToDB()
        
        dismiss(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modifyWorkViewController = segue.destination as! ModifyWorkViewController
        
        if segue.identifier == "EditWorkForCourse" {
            let row: Int = (workTabelView.indexPathForSelectedRow?.row)!
            modifyWorkViewController.navTitle = "Edit the Task"
            modifyWorkViewController.work = service.getCourse()?.courseworks[row]
            modifyWorkViewController.onSave = { work in
                self.service.updateWork(workIndex: row, newWork: work)
            }
        } else if segue.identifier == "AddWorkForCourse" {
            modifyWorkViewController.navTitle = "Add a Task"
            modifyWorkViewController.onSave = { work in
                self.service.addWork(newWork: work)
            }
        }
    }
    

}
