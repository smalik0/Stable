//
//  FirstViewController.swift
//  Pied Piper
//
//  Created by Saameh Malik on 10/1/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import UIKit
import Parse

class NearbyViewController: UITableViewController {

    
    
    
    var eventArray = [Events]()
    struct Events {
        
        var sectionName : String!
        var sectionObjects : [PFObject]!
    }
    
    func refreshData() {
        let query = PFQuery(className: "Events")
        
        query.findObjectsInBackgroundWithBlock {
            (storedEvents: [PFObject]?, error: NSError?) -> Void in
            if self.eventArray.count != 0 {
                self.eventArray = [Events]()
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat =  "hh:mm a 'on' EE MMM dd yyyy"
            var array: Dictionary<String, NSMutableArray> = [:]
            for event in storedEvents! {
                let eventTimeStr = event["TimeAndDate"] as! String
                let eventTime = dateFormatter.dateFromString(eventTimeStr)
                
                let eventDate = NSCalendar.currentCalendar().startOfDayForDate(eventTime!)
                let curDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
                if eventDate.compare(curDate) == NSComparisonResult.OrderedAscending {
                    event.deleteInBackground()
                }
                else {
                    let curLoc = event["Location"] as! String
                    if let locArray = array[curLoc] {
                        locArray.addObject(event)
                        array[curLoc] = locArray
                    } else {
                        array[curLoc] = NSMutableArray(array: [event])
                    }
                }
            }
            let sortedArray = array.sort{ $0.0 < $1.0 } //Sorts by alphabetical location! Adjust to sort by closeness to GPS position?
            
            for (key, value) in sortedArray {
                var tempArray = value as AnyObject as! [PFObject]
                tempArray.sortInPlace{
                    item1, item2 in
                    let time1 = item1["TimeAndDate"] as! String
                    let time2 = item2["TimeAndDate"] as! String
                    let NSTime1 = dateFormatter.dateFromString(time1)!
                    let NSTime2 = dateFormatter.dateFromString(time2)!
                    return NSTime1.compare(NSTime2) == NSComparisonResult.OrderedAscending
                }
                
                self.eventArray.append(Events(sectionName: key, sectionObjects: tempArray))
            }
            
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        refreshData()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray[section].sectionObjects.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return eventArray[section].sectionName
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: cellIdentifier)
        }
        
        let event = eventArray[indexPath.section].sectionObjects[indexPath.row]
        let label = event["Name"] as! String
        let sublabel = event["TimeAndDate"] as! String
        let truncatedsublabel = sublabel.substringToIndex(sublabel.startIndex.advancedBy(22))
        
        cell!.textLabel?.text = label
        cell!.detailTextLabel?.text = truncatedsublabel
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "showDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let selectedIndex = tableView.indexPathForSelectedRow {
                viewController.event = eventArray[selectedIndex.section].sectionObjects[selectedIndex.row]
            }
        }
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
    
    @IBAction func unwindToNearbyView(segue: UIStoryboardSegue) {
        refreshData()
    }

}

