//
//  LoginViewController.swift
//  Stable
//
//  Created by Saameh Malik on 11/12/15.
//  Copyright © 2015 Saameh Malik. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBAction func signIn(sender: AnyObject) {
        var complete = true
        for textField in [userName, password] {
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
            //Sign in
            loadingIndicator.startAnimating()
            PFUser.logInWithUsernameInBackground(userName.text!, password:password.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if let user = user {
                    // Do stuff after successful login.
                    let verified = user["emailVerified"] as! Bool
                    if verified {
                        if self.rememberUser.on {
                            user["RememberUser"] = true
                        }
                        else {
                            user["RememberUser"] = false
                        }
                        user.saveEventually()
                        self.performSegueWithIdentifier("signIn", sender: self)
                    }
                    else {
                        PFUser.logOut()
                        let alert = UIAlertController(title: "Error!", message: "Email not verified!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    // The login failed. Check error to see why.
                    
                    // Show the errorString somewhere and let the user try again.
                    
                    let alert = UIAlertController(title: "Error!", message: "Invalid username/password!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        var complete = true
        for textField in [userName] {
            let textInField = textField.text!
            if textInField.isEmpty {
                textField.layer.backgroundColor = UIColor.redColor().CGColor
                complete = false
            }
            else {
                textField.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
        }
        password.layer.backgroundColor = UIColor.whiteColor().CGColor
        if complete {
            PFUser.requestPasswordResetForEmailInBackground(userName.text!) {
                (success: Bool, error: NSError?) -> Void in
                
                
                if let error = error {
                    let errorString = error.userInfo["error"] as? String
                    // Show the errorString somewhere and let the user try again.
                    
                    let alert = UIAlertController(title: "Error!", message: errorString?.capitalizeFirst, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    
                    let alert = UIAlertController(title: "Reset email sent!", message: "Check your email to finish resetting your password", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }

    }
    @IBOutlet weak var rememberUser: UISwitch!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    override func viewDidLoad() {
        
        loadingIndicator.hidesWhenStopped = true
        super.viewDidLoad()
        let currentUser = PFUser.currentUser()
        if let currentUser = currentUser {
            if let remembered = currentUser["RememberUser"] as? Bool {
                if remembered {
                    rememberUser.setOn(true, animated: false)
                }
                else {
                    rememberUser.setOn(false, animated: false)
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        let currentUser = PFUser.currentUser()
        if let currentUser = currentUser {
            userName.text = currentUser.username
            let verified = currentUser["emailVerified"] as! Bool
            if let remembered = currentUser["RememberUser"] as? Bool {
                if verified && remembered {
                    self.performSegueWithIdentifier("signIn", sender: self)
                }
                else {
                    PFUser.logOut()
                }
            }
        }
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
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        if rememberUser.on {
            userName.text = PFUser.currentUser()?.username
            password.text = nil
        }
        else {
            userName.text = nil
            password.text = nil
        }
        PFUser.logOut()
    }

}

extension String {
    
    var capitalizeFirst:String {
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
}
