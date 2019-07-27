//
//  ImportProfileViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 25.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator
import HealthKit

class ImportProfileViewController : UIViewController {
    
    @IBOutlet weak var lbProfileName: UILabel!
    @IBOutlet weak var lbCreationDate: UILabel!
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var lbType: UILabel!
    
    @IBOutlet weak var swDeleteExistingData: UISwitch!
    @IBOutlet weak var pvImportProgress: UIProgressView!
    @IBOutlet weak var lbImportProgress: UILabel!
    @IBOutlet weak var aiImporting: UIActivityIndicatorView!
    @IBOutlet weak var btImport: UIButton!
    
    let healthStore  = HKHealthStore()
    
    var profile: HealthKitProfile?
    
    var importing = false {
        didSet {
            pvImportProgress.isHidden = !importing
            aiImporting.isHidden = !importing
            navigationItem.hidesBackButton = importing
            swDeleteExistingData.isEnabled = !importing
            btImport.isEnabled = !importing
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.importing          = false
        lbProfileName.text      = ""
        lbCreationDate.text     = ""
        lbVersion.text          = ""
        lbType.text             = ""
        lbImportProgress.text   = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        profile?.loadMetaData(true) { (metaData: HealthKitProfileMetaData) in
            OperationQueue.main.addOperation(){
                self.lbProfileName.text = metaData.profileName
                self.lbCreationDate.text = UIUtil.sharedInstance.formatDate(date: metaData.creationDate as NSDate?)
                self.lbVersion.text = metaData.version
                self.lbType.text = metaData.type
            }
        }
    }
    
    
    @IBAction func doImport(sender: AnyObject) {
        importing = true
        lbImportProgress.text = "Start import"
        if let importProfile = profile {
            let importer = HealthKitProfileImporter(healthStore: healthStore)
            importer.importProfile(
                importProfile,
                deleteExistingData: swDeleteExistingData.isOn,
                onProgress: {(message: String, progressInPercent: NSNumber?)->Void in
                    OperationQueue.main.addOperation(){
                        self.lbImportProgress.text = message
                        if let progress = progressInPercent {
                            self.pvImportProgress.progress = progress.floatValue
                        }
                    }
                },
                
                onCompletion: {(error: Error?)-> Void in
                    OperationQueue.main.addOperation(){
                        if let exportError = error {
                            self.lbImportProgress.text = "Import error: \(exportError)"
                            print(exportError)
                        }
                        
                        self.importing = false
                    }
                }
            )
        }
    }
    
}
