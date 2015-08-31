/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var messagesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview delegate and data source
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // textfield delegate
        messageTextField.delegate = self
        
        // tap gesture recognizer
        let tabGesture = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        messageTableView.addGestureRecognizer(tabGesture)
        
        self.retrieveMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        // send button is tapped
        
        // call end editing method for the text field
        self.messageTextField.endEditing(true)
        
        // disable send button and textfeild
        messageTextField.enabled = false
        sendButton.enabled = false
        
        // create pfobject
        var newMessage = PFObject(className: "Message")
        
        println(messageTextField.text)
        
        // set the text key to value of textfield
        newMessage["Text"] = messageTextField.text
        
        // save the object
        newMessage.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                // message saved!
                self.retrieveMessages()
                NSLog("Message saved successfully")
            }
            else {
                // there was a problem check error.description
                NSLog(error!.description)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // enable textfield and button
                self.messageTextField.enabled = true
                self.sendButton.enabled = true
                self.messageTextField.text = ""
            }
            
        }
        
    }
    
    func retrieveMessages() {
        
        // create new pfquery
        var query = PFQuery(className: "Message")
        
        // call findobjectsinbackground
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            
            // clear messagesArray
            self.messagesArray = [String]()
            
            // loop thru objects array
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for messageObject in objects {
                        // retrieve text column of each pfobject
                        let messageText:String? = (messageObject as PFObject)["Text"] as? String
                        
                        // assign into messagesArray
                        if messageText != nil {
                            self.messagesArray.append(messageText!)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    // reload
                    self.messageTableView.reloadData()
                }
                
            }
            else {
                NSLog(error!.description)
            }
            
            
        }
        
    }
    
    func tableViewTapped() {
        
        // force textfield to end editing
        messageTextField.endEditing(true)
        
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // perform animation
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 300
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        // perform animation
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    // MARK: TableVew Delegate Methods
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // create cell
        let cell = messageTableView.dequeueReusableCellWithIdentifier("MessageCell") as! UITableViewCell
        
        // customize cell
        cell.textLabel?.text = messagesArray[indexPath.row]
        
        // return cell
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
        
    }
    
    
}
