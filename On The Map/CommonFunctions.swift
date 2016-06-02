//
//  CommonFunctions.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/16.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation
import UIKit

enum Error: Int {
    case Exception = 0
    case BadRequest
    case Forbidden
    case NotFound
    case Unknown
}

extension UIViewController {
    
    func displayError(errorString: String?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let alertCtrl = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertCtrl.addAction(okAction)
            self.presentViewController(alertCtrl, animated: true, completion: nil)
        })
    }

    func removeViewAsync(view: UIView) {
        
        dispatch_async(dispatch_get_main_queue(), {
            view.removeFromSuperview()
        })
    }
}