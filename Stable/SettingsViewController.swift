//
//  SettingsViewController.swift
//  Pied Piper
//
//  Created by Saameh Malik on 10/14/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SettingsViewController: UIViewController {
    
    let dorms = ["North Mountain", "Red Bricks", "Towers", "PCV"]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dorms.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return dorms[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

