//
//  ModifyWorkViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/4.
//

import UIKit
import UserNotifications

class ModifyWorkViewController: UIViewController, UITextFieldDelegate {
    
    private let service = Service.sharedInstance
    var navTitle: String = "Modify the Task"
    var work: Work?
    var onSave: ((Work) -> Void)?
    
    let notificationService = NotificationService.sharedInstance
    let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var modifyNavItem: UINavigationItem!
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var notifySwitch: UISwitch!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss keyboard setup
        self.hideKeyboardWhenTappedAround()
        
        // config title
        modifyNavItem.title = navTitle
        
        // config workTextField
        workTextField.text = work?.title
        saveButton.isEnabled = !(workTextField.text?.trimmingCharacters(in: .whitespaces) ?? "").isEmpty
        
        // config notify switch
        notifySwitch.isOn = work?.isNotify ?? false
        
        // config date picker
//        dueDatePicker.minimumDate = Date()
        dueDatePicker.date = work?.due ?? Date()
        
        // config notification
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if !success {
                print("Permission Denied")
            }
        }
    }
    
    
    // for textfield config
    func textFieldDidChangeSelection(_ textField: UITextField) {
        saveButton.isEnabled = !(workTextField.text?.trimmingCharacters(in: .whitespaces) ?? "").isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // for bar button item tapped
    @IBAction func cancelButtonDidTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonDidTapped(_ sender: UIBarButtonItem) {
        // grab notification info
        let courseTitle = (service.getCourse()?.title)!
        let workTitle = workTextField.text!
        
        // construct notification detail
        let title = "Counager Notification"
        let message = "\(courseTitle) \(workTitle)\nYour Assignment is gonna due within 24h!"
        let date = dueDatePicker.date  // .addingTimeInterval(-something)
        
        // generate an unique ID
        let identifier = UUID().uuidString
        
        // generate notification object
        let notification = Notification(
            identifier: identifier,
            title: title,
            message: message,
            date: date
        )
        
        /* update notification service depend on chagnes */
        var newNotifyId: String? = nil
        
        // if we reschedule the notification
        if work?.due != dueDatePicker.date {
            if work?.isNotify ?? false {
                notificationService.needToDisable.append((work?.notifyId)!)
                newNotifyId = nil
            }
            
            if notifySwitch.isOn {
                notificationService.needToAble.append(notification)
                newNotifyId = identifier
            }
        }
        // if we didn't change the schedule date
        else {
            if !(work?.isNotify ?? false) && notifySwitch.isOn {
                notificationService.needToAble.append(notification)
                newNotifyId = identifier
            }
            else if work?.isNotify ?? false && !notifySwitch.isOn {
                notificationService.needToDisable.append((work?.notifyId)!)
                newNotifyId = nil
            }
        }
        
        // save work data
        let newWork = Work(
            title: workTextField.text!,
            due: dueDatePicker.date,
            isNotify: notifySwitch.isOn,
            notifyId: newNotifyId
        )
        onSave?(newWork)
    
        dismiss(animated: true)
    }
    
    
    // present if don't have permission
    private func presentFailSchedule() {
        let actionController = UIAlertController(title: "Enable Notifications?", message: "To use this feature you must enable notification in settings", preferredStyle: .alert)
        
        // action to setting
        let goToSettings = UIAlertAction(title: "Setting", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if(UIApplication.shared.canOpenURL(settingsURL)) {
                UIApplication.shared.open(settingsURL) { _ in }
            }
        }
        // action to nothing
        let deny = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        actionController.addAction(goToSettings)
        actionController.addAction(deny)
        self.present(actionController, animated: true)
    }
    
    // for notification switch tapped
    @IBAction func notifySwitchDidTapped(_ sender: UISwitch) {
        // we try to turn on switch
        if notifySwitch.isOn {
            notificationCenter.getNotificationSettings { settings in
                // if we don't have authorization
                if settings.authorizationStatus != .authorized {
                    DispatchQueue.main.async {
                        self.notifySwitch.isOn = false
                        self.presentFailSchedule()      // gently ask for it
                    }
                }
            }
        }
    }
    
}
