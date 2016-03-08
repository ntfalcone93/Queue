//
//  QueueTableViewController.swift
//  Queue
//
//  Created by Taylor Mott on 3/8/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CloudKit

class QueueTableViewController: UITableViewController {
    
    var records = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCurrentQueue { (success) -> Void in
            print("Did we succeed? -> \(success)")
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            } else {
                print("Fetch was not successful")
            }
        }
    }
    
    @IBAction func subscribeButtonTapped() {
        
        let predicate = NSPredicate(format: "wasAnswered == 0")
        
        let subscription = CKSubscription(recordType: "Question", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["body", "studentName"]
        
        subscription.notificationInfo = notificationInfo
        
        CKContainer.defaultContainer().publicCloudDatabase.saveSubscription(subscription) { (savedSubscription, error) -> Void in
            if error != nil {
                print("Error subscribing to push notifications: \(error?.localizedDescription)")
            } else {
                print("\(savedSubscription)")
            }
        }
    }
    
    func fetchCurrentQueue(completion: (success: Bool) -> Void) {
        let publicDataBase = CKContainer.defaultContainer().publicCloudDatabase
        
        let predicate = NSPredicate(format: "wasAnswered == 0")
        
        let query = CKQuery(recordType: "Question", predicate: predicate)
        
        publicDataBase.performQuery(query, inZoneWithID: nil) { (recordsReturned, error) -> Void in
            if error != nil {
                print("Error fetching question: \(error?.localizedDescription)")
                completion(success: false)
            } else {
                guard let recordsReturned = recordsReturned else { completion(success: false); return }
                
                let orderedRecords = recordsReturned.sort({
                    let date0 = $0.creationDate ?? NSDate()
                    let date1 = $1.creationDate ?? NSDate()
                    
                    return date0.timeIntervalSinceDate(date1) <= 0
                })
                 self.records = orderedRecords
                completion(success: true)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subtitleCell", forIndexPath: indexPath)
        
        let record = records[indexPath.row]
        
        cell.textLabel?.text = record["body"] as? String
        
        if let studentName = record["studentName"] as? String, creationDate = record.creationDate {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateStyle = .ShortStyle
            let dateString = dateFormatter.stringFromDate(creationDate)
            cell.detailTextLabel?.text = "\(studentName) - \(dateString)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
