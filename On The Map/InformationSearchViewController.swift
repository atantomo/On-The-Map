//
//  InformationSearchViewController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/15.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import MapKit

class InformationSearchViewController: UIViewController {

    var localSearchResponse:MKLocalSearchResponse!

    @IBOutlet weak var locationTextField: InsetTextField!

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func findButtonTapped(sender: UIButton) {

        let allFieldsFilled = locationTextField.text != ""
        guard allFieldsFilled else {
            displayError("Please fill in your location")
            return
        }

        let blockerView = BlockerView(frame: view.frame)
        blockerView.backgroundShade.backgroundColor = UIColor.blackColor()
        blockerView.backgroundShade.alpha = 0.3
        view.addSubview(blockerView)
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { localSearchResponse, error in

            self.removeViewAsync(blockerView)

            if let err = error {
                print("Request returned an error: \(err)")
            }
            
            if localSearchResponse == nil {
                self.displayError("Location not found")
                return
            }

            self.localSearchResponse = localSearchResponse
            self.performSegueWithIdentifier("LocationResultSegue", sender: self)
        }
    }

    @IBAction func cancelButtonTapped(sender: UIButton) {

        dismissViewControllerAnimated(true, completion: nil)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "LocationResultSegue" {
            let infoPostVc = segue.destinationViewController as! InformationPostingViewController

            // Only read the first result
            let firstResult = localSearchResponse.mapItems[0]
            infoPostVc.latitude = firstResult.placemark.coordinate.latitude
            infoPostVc.longitude = firstResult.placemark.coordinate.longitude
            infoPostVc.locationTitle = firstResult.name
        }
    }
}

extension InformationSearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}