//
//  FirstViewController.swift
//  Pied Piper
//
//  Created by Saameh Malik on 10/1/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

class NearbyViewController: UITableViewController, CLLocationManagerDelegate, SettingsViewControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    
    var locationManager: CLLocationManager!
    
    let dorms = ["North Mountain": [10,70], "Red Bricks":[-50,-50], "Towers": [0,0], "PCV": [30, -80]]
    var curLoc: CLLocation!
    
    var resultSearchController = UISearchController()
    
    var sortMethod: String?
    
    
    var eventArray = [Events]()
    var filteredEventArray = [Events]()
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
            var locArray: [String] = []
            if let curLoc = self.curLoc {
                let locSortedArray = array.keys.sort {
                    dorm1, dorm2 in
                    let loc1 = self.dorms[dorm1]!
                    let loc2 = self.dorms[dorm2]!
                    let coord1 = CLLocation(latitude: Double(loc1.first!), longitude: Double(loc1.last!))
                    let coord2 = CLLocation(latitude: Double(loc1.first!), longitude: Double(loc2.last!))
                    let distance1 = curLoc.distanceFromLocation(coord1)
                    let distance2 = curLoc.distanceFromLocation(coord2)
                    return distance1 < distance2
                }
                locArray = locSortedArray
            }
            var finalArray: [String] = []
            if self.sortMethod == "Alphabetical" {
                finalArray = Array(array.keys).sort(<)
            } else if self.sortMethod == "Nearest You" && locArray != [] {
                finalArray = locArray
            } else {
                finalArray = Array(array.keys).sort(<)
            }
            for key in finalArray {
                var tempArray = array[key] as! AnyObject as! [PFObject]
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
        sortMethod = PFUser.currentUser()!["SortMode"] as? String
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        refreshData()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        self.resultSearchController.searchBar.placeholder = "Search events"
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        curLoc = locations.last! as CLLocation
        
        //curLoc = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
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
        if (self.resultSearchController.active) {
            return filteredEventArray.count
        }
        
        return eventArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return filteredEventArray[section].sectionObjects.count
        }
        return eventArray[section].sectionObjects.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.resultSearchController.active) {
            return filteredEventArray[section].sectionName
        }
        
        return eventArray[section].sectionName
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: cellIdentifier)
        }
        var event: PFObject
        if (self.resultSearchController.active) {
            event = filteredEventArray[indexPath.section].sectionObjects[indexPath.row]
        }
        else {
            event = eventArray[indexPath.section].sectionObjects[indexPath.row]
        }
        
        let label = event["Name"] as! String
        let sublabel = event["TimeAndDate"] as! String
        let truncatedsublabel = sublabel.substringToIndex(sublabel.startIndex.advancedBy(22))
        
        cell!.textLabel?.text = label
        cell!.detailTextLabel?.text = truncatedsublabel
        
        return cell!
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredEventArray = [Events]()
        for var i = 0; i < eventArray.count; ++i {
            var tempArray: [PFObject] = []
            for var j = 0; j < eventArray[i].sectionObjects.count; ++j {
                let event = eventArray[i].sectionObjects[j]
                let name = event["Name"] as! String
                if (name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil) {
                    tempArray.append(event)
                }
                
            }
            if tempArray.count > 0 {
                self.filteredEventArray.append(Events(sectionName: eventArray[i].sectionName, sectionObjects: tempArray))
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
        self.tableView.reloadData()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "showDetail" {
            let viewController = segue.destinationViewController as! DetailViewController
            if let selectedIndex = tableView.indexPathForSelectedRow {
                if (self.resultSearchController.active) {
                    viewController.event = filteredEventArray[selectedIndex.section].sectionObjects[selectedIndex.row]
                    self.resultSearchController.active = false
                    
                }
                else {
                    viewController.event = eventArray[selectedIndex.section].sectionObjects[selectedIndex.row]
                }
            }
        }
        else if segue.identifier == "showSettings" {
            let viewController = segue.destinationViewController as! SettingsViewController
            viewController.delegate = self
        }
    }
    
    func controller(controller: SettingsViewController, newSortMethod: String) {
        sortMethod = newSortMethod
        refreshData()
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

