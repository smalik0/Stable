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

protocol SettingsViewControllerDelegate {
    func controller(controller: SettingsViewController, newSortMethod: String)
}

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    var delegate: SettingsViewControllerDelegate?
    
    @IBOutlet weak var sortField: UITextField!
    let sortOptions = ["Alphabetical", "Nearest You"]
    let pickerView = UIPickerView()
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortField.text = sortOptions[row]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissPicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        sortField.inputView = pickerView
        sortField.inputAccessoryView = toolBar
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func dismissKeyboard(){
        view.endEditing(true)
    }
    func dismissPicker() {
        sortField.text = sortOptions[pickerView.selectedRowInComponent(0)]
        dismissKeyboard()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        var complete = true
        for textField in [sortField] {
            let textInField = textField.text!
            if textInField.isEmpty {
                textField.layer.backgroundColor = UIColor.redColor().CGColor
                complete = false
            }
            else {
                textField.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
        }
        if complete {
            let sortMethod = sortField.text!
            if let delegate = self.delegate {
                delegate.controller(self, newSortMethod: sortMethod)
            }
            self.performSegueWithIdentifier("exitSettings", sender: self)
        }
    }
    
}

