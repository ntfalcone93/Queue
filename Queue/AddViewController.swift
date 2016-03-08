//
//  AddViewController.swift
//  Queue
//
//  Created by Taylor Mott on 3/8/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CloudKit

class AddViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var studentNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitQuestionButtonTapped() {
        let record = CKRecord(recordType: "Question")
        // Set object
        record.setObject(questionTextField.text ?? "", forKey: "body")
        // Dictionary way of storing the value
        record["studentName"] = studentNameTextField.text ?? ""
        
        record["wasAnswered"] = NSNumber(bool: false) // Set bool to 0 if false
        
        let container = CKContainer.defaultContainer()
        
        container.publicCloudDatabase.saveRecord(record) { (savedRecord, error) -> Void in
            if error != nil {
                // Failure
                // Check for error codes
//                switch CKErrorCode {
//                    
//                }
                print("Error: \(error?.localizedDescription)")
            } else {
                // Success
                print("Record saved: \(savedRecord)")
            }
            
        }
        
        // You can create new properties as well
//        record["myRandomProperty"] = "random text"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
