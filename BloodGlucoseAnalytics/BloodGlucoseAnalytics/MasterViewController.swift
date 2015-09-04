//
//  MasterViewController.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit
import UIKit


class MasterViewController: UITableViewController {
    
    let kAuthorizeHealthKitSection = 2
    let kProfileSegueIdentifier = "profileSegue"
    let kWorkoutSegueIdentifier = "workoutsSeque"
    let kUnknownString   = "Unknown"
    let healthManager:HealthManager = HealthManager()
    let mgdlUnit = HKUnit(fromString: "mg/dL")
  
    @IBOutlet var lastBgLabel: UILabel!
    @IBOutlet weak var lastBGValueLabel: UILabel!
    
    var BG:HKQuantitySample?
    
    //set value of lastbg
    //self.lastBgValueLabel.text = "100"
    
    func updateBGValues(){
        updateLastBG()
    }
    
    func updateLastBG(){
        lastBgLabel.text = String("Last BG: 100")
        
        // 1. Construct an HKSampleType for weight
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)
        
        // 2. Call the method to read the most recent weight sample
        self.healthManager.readMostRecentSample(sampleType, completion: { (mostRecentBG, error) -> Void in
            
            if( error != nil )
            {
                println("Error reading BG from HealthKit Store: \(error.localizedDescription)")
                return;
            }
            
            var glucoLocalizedString = self.kUnknownString;
            // 3. Format the weight to display it on the screen
            self.BG = mostRecentBG as? HKQuantitySample;
            
            if let mgdl = self.BG?.quantity.doubleValueForUnit(self.mgdlUnit) {
                //glucoFormatter.forPersonMassUse = true;
                glucoLocalizedString = "Last Glucose reading: " + mgdl.description
            } else {
                println("error reading glucose data")
            }
            
            // 4. Update UI in the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.lastBgLabel.text = glucoLocalizedString
                //self.updateBMI()
                
            });
        })
        
    }
    
    func authorizeHealthKit()
    {
        // println("TODO: Request HealthKit authorization")
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            }
            else
            {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBGValues()
    }
  
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier ==  kProfileSegueIdentifier {
            
            if let profileViewController = segue.destinationViewController as? ProfileViewController {
                profileViewController.healthManager = healthManager
            }
        }
        else if segue.identifier == kWorkoutSegueIdentifier {
            if let workoutViewController = segue.destinationViewController.topViewController as? WorkoutsTableViewController {
                workoutViewController.healthManager = healthManager;
            }
        }
    }
    
    // MARK: - TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section, indexPath.row)
        {
        case (kAuthorizeHealthKitSection,0):
            authorizeHealthKit()
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
}
