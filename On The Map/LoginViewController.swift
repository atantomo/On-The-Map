//
//  LoginViewController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/09.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: InsetTextField!
    @IBOutlet weak var passwordTextField: InsetTextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let fbToken = FBSDKAccessToken.currentAccessToken() {
            loginWithFbToken(fbToken)
        }
        fbLoginButton.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTapped(sender: UIButton) {

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        let allFieldsFilled = emailTextField.text != "" && passwordTextField.text != ""
        guard allFieldsFilled else {
            displayError("Please fill in your username and password")
            return
        }

        let channel = UdacityClient.JSONBodyKeys.Udacity
        let params = [
            UdacityClient.JSONBodyKeys.Username: emailTextField.text!,
            UdacityClient.JSONBodyKeys.Password: passwordTextField.text!
        ]

        let blockerView = BlockerView(frame: view.frame)
        view.addSubview(blockerView)
        UdacityClient.sharedInstance().login(channel, params: params) { success, errorString in

            self.removeViewAsync(blockerView)
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }

    @IBAction func signUpButtonTapped(sender: UIButton) {

        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.sharedApplication().openURL(url)
        return
    }
    
    func completeLogin() {

        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("TopNavigationSegue", sender: nil)
        })
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {


    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if let err = error {
            self.displayError(err.localizedDescription)
            return
        }

        loginWithFbToken(result.token)
    }

    func loginWithFbToken(fbToken: FBSDKAccessToken?) {

        guard let token = fbToken else {
            displayError("Could not retrieve authentication token")
            return
        }

        let channel = UdacityClient.JSONBodyKeys.FacebookMobile
        let params = [
            UdacityClient.JSONBodyKeys.AccessToken: token.tokenString!
        ]

        let blockerView = BlockerView(frame: view.frame)
        view.addSubview(blockerView)
        UdacityClient.sharedInstance().login(channel, params: params) { success, errorString in

            self.removeViewAsync(blockerView)
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

        return
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
