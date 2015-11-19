//
//  DetailViewController.swift
//  Pied Piper
//
//  Created by Saameh Malik on 10/14/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import Foundation
import UIKit
import Parse

class DetailViewController: UIViewController {
    
    var event: PFObject!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var locationDetails: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = event["Name"] as? String
        // Do any additional setup after loading the view, typically from a nib.
        location.text = event["Location"] as? String
        locationDetails.text = event["LocationDetails"] as? String
        time.text = event["TimeAndDate"] as? String
        details.lineBreakMode = NSLineBreakMode.ByWordWrapping
        details.sizeToFit()
        details.numberOfLines = 0
        details.text = event["Details"] as? String
        postedBy.text = event["Creator"] as? String
        if postedBy.text == PFUser.currentUser()?.username {
            deleteButton.hidden = false
            deleteButton.tintColor = UIColor.redColor()
        }
        else {
            deleteButton.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func remind(sender: AnyObject) {
        
        let ITEMS_KEY = "StableEvents"
        var notificationDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        let objId = event.objectId!
        
        let dateStr = self.event["TimeAndDate"] as? String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "hh:mm a 'on' EE MMM dd yyyy"
        let date = dateFormatter.dateFromString(dateStr!)
        if NSDate().compare(date!) == NSComparisonResult.OrderedAscending {
            if notificationDictionary[objId] == nil {
            
                let alertController = UIAlertController(title: "Remind me", message: "Select a reminder time", preferredStyle: .ActionSheet)
                let atTimeOF = UIAlertAction(title: "At Time of Event", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.addNotificationForEvent(0)
                })
                let tenMin = UIAlertAction(title: "10 Minutes Before Event", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.addNotificationForEvent(10)
                })
                
                let thirtyMin = UIAlertAction(title: "30 Minutes Before Event", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.addNotificationForEvent(30)
                })
                
                let sixtyMin = UIAlertAction(title: "1 Hour Before Event", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.addNotificationForEvent(60)
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(atTimeOF)
                alertController.addAction(tenMin)
                alertController.addAction(thirtyMin)
                alertController.addAction(sixtyMin)
                alertController.addAction(cancel)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
                
            else {
                let minutesBefore = notificationDictionary[objId]!["minBefore"]!!.intValue
                var name2 = ""
                if minutesBefore == 60 {
                    name2 = "1 hour before"
                }
                else if minutesBefore == 0 {
                    name2 = "time of"
                }
                else {
                    name2 = "\(minutesBefore) minutes before"
                }
                let alertController = UIAlertController(title: "Remind me", message: "Reminder already set for " + name2 + " event!", preferredStyle: .ActionSheet)
                
                let delete = UIAlertAction(title: "Delete Notification", style: .Destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.removeEvent(self.event)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(delete)
                alertController.addAction(cancel)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        else {
            let alertController = UIAlertController(title: "Uh oh!", message: "Event has already started!", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(ok)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func addNotificationForEvent(minutesBefore: Int) {
        
        let ITEMS_KEY = "StableEvents"
        var notificationDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary()
        
        let objId = event.objectId!
        let notification = UILocalNotification()
        let name = self.event["Name"] as! String
        var name2 = ""
        if minutesBefore == 60 {
            name2 = " starts in 1 hour"
        }
        else if minutesBefore == 0 {
            name2 = " starts now"
        }
        else {
            name2 = " starts in \(minutesBefore) minutes"
        }
        notification.alertBody = name + name2
        let dateStr = self.event["TimeAndDate"] as? String
        notification.userInfo = ["ID": objId, "minBefore": minutesBefore]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "hh:mm a 'on' EE MMM dd yyyy"
        let date = dateFormatter.dateFromString(dateStr!)
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        let notificationDate = calendar.dateByAddingUnit(.Minute, value: -minutesBefore, toDate: date!, options: [])
        notification.fireDate = notificationDate
        if NSDate().compare(notificationDate!) == NSComparisonResult.OrderedDescending {
            let alertController = UIAlertController(title: "Uh oh!", message: "Scheduled reminder time has already passed!", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(ok)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            notificationDictionary[objId] = ["event": objId, "minBefore": minutesBefore] // store NSData representation of todo item in dictionary with UUID as key
            NSUserDefaults.standardUserDefaults().setObject(notificationDictionary, forKey: ITEMS_KEY)
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    @IBAction func deleteEvent(sender: AnyObject) {
        let alertController = UIAlertController(title: "Confirm", message: "Delete event?", preferredStyle: .Alert)
        let delete = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.event.deleteInBackgroundWithBlock({
                (success, Error) -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func removeEvent(event: PFObject) {
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for notification in notifications { // loop through notifications...
                if (notification.userInfo?["ID"] as? String == event.objectId) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                    UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                    break
                }
            }
        }
        let ITEMS_KEY = "StableEvents"
        if var todoItems = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
            todoItems.removeValueForKey(event.objectId!)
            NSUserDefaults.standardUserDefaults().setObject(todoItems, forKey: ITEMS_KEY) // save/overwrite todo item list
        }
    }
    
}

