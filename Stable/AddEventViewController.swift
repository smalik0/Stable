//
//  AddEventViewController.swift
//  Pied Piper
//
//  Created by Saameh Malik on 10/14/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import Foundation
import UIKit
import Parse

class AddEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventLocationDetails: UITextField!
    @IBOutlet weak var eventTime: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventDetails: UITextView!
    let pickerView = UIPickerView()
    let datePickerView = UIDatePicker()
    
    @IBAction func submitEvent(sender: AnyObject) {
        var complete = true
        for textField in [eventName, eventLocation, eventTime] {
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
            loadingIndicator.startAnimating()
            let event = PFObject(className: "Events")
            event["Name"] = eventName.text
            event["Location"] = eventLocation.text
            event["TimeAndDate"] = eventTime.text
            if let locationDetails = eventLocationDetails.text {
                event["LocationDetails"] = locationDetails
            }
            if let extraDetails = eventDetails.text {
                event["Details"] = extraDetails
            }
            event.saveInBackgroundWithBlock() {
                (success, error) in
                if success {
                    self.loadingIndicator.stopAnimating()
                    self.performSegueWithIdentifier("exitAddEvent", sender: self)
                }
                
            }
        }
        
    }
    
    let dorms = ["North Mountain", "Red Bricks", "Towers", "PCV"]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dorms.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dorms[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventLocation.text = dorms[row]
    }
    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat =  "hh:mm a 'on' EE MMM dd yyyy"
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        eventTime.text = strDate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadingIndicator.hidesWhenStopped = true
        let color = UIColor.grayColor()
        eventDetails.layer.borderColor = color.CGColor
        eventDetails.layer.borderWidth = 0.5
        eventDetails.layer.cornerRadius = 8.0
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissPicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let dateToolBar = UIToolbar()
        dateToolBar.barStyle = UIBarStyle.Default
        dateToolBar.translucent = true
        dateToolBar.sizeToFit()
        let dateDoneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissDatePicker")
        let dateTodayButton = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: "selectToday")
        
        dateToolBar.setItems([dateTodayButton,spaceButton,dateDoneButton], animated: false)
        dateToolBar.userInteractionEnabled = true
        
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        datePickerView.minimumDate = NSDate()
        datePickerView.minuteInterval = 5
        
        eventLocation.inputView = pickerView
        eventLocation.inputAccessoryView = toolBar
        eventTime.inputView = datePickerView
        eventTime.inputAccessoryView = dateToolBar
        datePickerView.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(){
        eventDetails.resignFirstResponder()
        view.endEditing(true)
    }
    
    func dismissPicker() {
        eventLocation.text = dorms[pickerView.selectedRowInComponent(0)]
        dismissKeyboard()
    }
    
    func dismissDatePicker() {
        datePickerChanged(datePickerView)
        dismissKeyboard()
    }
    
    func selectToday() {
        datePickerView.setDate(NSDate(), animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) {
        dismissKeyboard()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        animateViewMoving(true, moveValue: 150)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animateViewMoving(false, moveValue: 150)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            dismissKeyboard()
            return false
        }
        return true
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
}

