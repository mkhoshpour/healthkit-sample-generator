//
//  ProfilesTableViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 23.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator

class ProfilesTableViewController: UITableViewController {
    

    var profiles:[HealthKitProfile] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        profiles = HealthKitProfileReader.readProfilesFromDisk(documentsUrl)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // make sure the table view is not in editing mode
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView" {
            let detailViewController = segue.destination as! ImportProfileViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                 detailViewController.profile = profiles[indexPath.row]
            }
        }
    }
    
}

// TableView DataSource
extension ProfilesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profile = profiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")!
        
        cell.textLabel?.text = profile.fileName
        
        profile.loadMetaData(true) { (metaData:HealthKitProfileMetaData) in

            OperationQueue.main.addOperation(){
                
                let from = UIUtil.sharedInstance.formatDate(date: metaData.creationDate as NSDate?)
                let profileName = metaData.profileName != nil ? metaData.profileName! : "unknown"
                
                cell.detailTextLabel?.text = "\(profileName) from: \(from)"
            }

        }
        return cell
        
    }
    
}

// UITableViewDelegate
extension ProfilesTableViewController {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let profile = profiles[indexPath.row]
            
            let alert = UIAlertController(
                            title: "Delete Profile \(profile.fileName)",
                            message: "Do you really want to delete this prolfile? The file will be deleted! This can not be undone!",
                            preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes, delete it!", style: .destructive, handler: { action in
                do {
                    try profile.deleteFile()
                    self.profiles.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with:.automatic)
                } catch let error {
                    let errorAlert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
