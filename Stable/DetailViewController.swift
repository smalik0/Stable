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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func remind(sender: AnyObject) {
    }
    
}

