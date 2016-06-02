//
//  TabbedController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/16.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TabbedController: UITabBarController {

    var userExists: Bool = false

    @IBAction func logoutButtonTapped(sender: UIBarButtonItem) {

        let blockerView = BlockerView(frame: view.frame)
        view.addSubview(blockerView)

        if let _ = FBSDKAccessToken.currentAccessToken() {
            let loginMgr = FBSDKLoginManager()
            loginMgr.logOut()
        }

        UdacityClient.sharedInstance().logout() {  success, errorString in

            self.removeViewAsync(blockerView)
            if success {
                self.completeLogout()
            } else {
                self.displayError(errorString)
            }
        }
    }

    @IBAction func postButtonTapped(sender: UIBarButtonItem) {

        if (userExists) {
            let alertCtrl = UIAlertController(title: "Notice", message: "Your location has already been recorded. Would you like to overwrite your previous location?", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default) { action in
                self.performSegueWithIdentifier("LocationSearchSegue", sender: self)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            alertCtrl.addAction(okAction)
            alertCtrl.addAction(cancelAction)

            self.presentViewController(alertCtrl, animated: true, completion: nil)

        } else {

            performSegueWithIdentifier("LocationSearchSegue", sender: self)

        }

    }

    func completeLogout() {

        dispatch_async(dispatch_get_main_queue(), {

            guard let navCtrl = self.navigationController else {
                return
            }

            let loginVc = navCtrl.presentingViewController!
            navCtrl.dismissViewControllerAnimated(true) {

                let alertCtrl = UIAlertController(title: "Logged out", message: "Please come back again!", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertCtrl.addAction(okAction)
                loginVc.presentViewController(alertCtrl, animated: true, completion: nil)
            }
        })
    }

    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {

        refreshVcData()
    }

    func refreshVcData() {

        print(selectedViewController)
        if let currentVc = selectedViewController {

            if let mapVc = currentVc as? TabbedMapViewController {
                mapVc.reloadStudentAnnotations()
            } else if let tableVc = currentVc as? TabbedTableViewController {
                tableVc.reloadStudentInformation()
            }
        }
    }
}