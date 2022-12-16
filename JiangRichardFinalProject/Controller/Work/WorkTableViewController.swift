//
//  WorkTableViewController.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/3.
//

import UIKit

class WorkTableViewController: UITableViewController {
    private var service = Service()
    private var works = [Work]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
        self.tableView.reloadData()
    }
    
    func load() {
        Task.init {
            do {
                works = try await service.getAllWork()
            } catch {
                print(error)
            }
        }
    }

    // return number of cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of work
        return works.count
    }

    // config individual cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkTableCell", for: indexPath) as! WorkTableViewCell
        let work = works[indexPath.row]
        
        // config the cell
        cell.workLabel?.text = work.title
        cell.dueLabel?.text = work.due.formatted()
        cell.courseLabel?.text = work.course ?? "Not coursework"

        return cell
    }
    
    // set height of tableview cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // if edit button tapped
    @IBAction func editButtonDidTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.isEditing = false
            sender.title = "Edit"
        } else {
            tableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    // editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modifyWorkViewController = segue.destination as! ModifyWorkViewController
        
        if segue.identifier == "EditWorkSegue" {
            let row: Int = (tableView.indexPathForSelectedRow?.row)!
            
            modifyWorkViewController.navTitle = "Edit the Task"
            modifyWorkViewController.work = works[row]
            modifyWorkViewController.onSave = { work in
                self.service.setWork(work: work)
            }
        } else if segue.identifier == "AddWorkSegue" {
            modifyWorkViewController.navTitle = "Add a Task"
            modifyWorkViewController.onSave = { work in
                self.service.addWork(work: work)
                // if course is one of them, add this reference above
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
