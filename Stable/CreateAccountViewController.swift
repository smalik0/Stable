//
//  CreateAccountViewController.swift
//  Stable
//
//  Created by Saameh Malik on 11/12/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import UIKit
import Parse

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func createAccount(sender: AnyObject) {
        var complete = true
        for textField in [userName, password, passwordConfirm] {
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
            if password.text == passwordConfirm.text {
                if userName.text!.hasSuffix("@calpoly.edu") {
                    
                    let user = PFUser()
                    user.username = userName.text
                    user.email = userName.text
                    user.password = password.text
                    user.signUpInBackgroundWithBlock {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if let error = error {
                            let errorString = error.userInfo["error"] as? String
                            // Show the errorString somewhere and let the user try again.
                            
                            let alert = UIAlertController(title: "Error!", message: errorString?.capitalizeFirst, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            // Hooray! Let them use the app now.
                            
                            let alert = UIAlertController(title: "Account created!", message: "Verification email sent", preferredStyle: UIAlertControllerStyle.Alert)
                            let alertPressed = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                self.performSegueWithIdentifier("exitCreateAccount", sender: self)
                            }
                            alert.addAction(alertPressed)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "Error!", message: "Not a CalPoly email!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            }
            else {
                let alert = UIAlertController(title: "Error!", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
