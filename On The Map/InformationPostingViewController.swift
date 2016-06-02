//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var urlTextField: InsetTextField!
    @IBOutlet weak var mapView: MKMapView!

    var locationTitle: String!
    var latitude: Double!
    var longitude: Double!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupAnnotation()
        urlTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {

        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(initialLocation)
    }

    private func centerMapOnLocation(location: CLLocation) {

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    private func setupAnnotation() {

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.title = UdacityClient.sharedInstance().firstName! + " " + UdacityClient.sharedInstance().lastName!
        pointAnnotation.subtitle = locationTitle

        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
        mapView.addAnnotation(pinAnnotationView.annotation!)
    }

    @IBAction func submitButtonTapped(sender: UIButton) {

        let allFieldsFilled = urlTextField.text != ""
        guard allFieldsFilled else {
            displayError("Please fill in your url")
            return
        }

        let blockerView = BlockerView(frame: view.frame)
        blockerView.backgroundShade.backgroundColor = UIColor.blackColor()
        blockerView.backgroundShade.alpha = 0.3
        view.addSubview(blockerView)
        
        let postLocation = StudentInformation(dictionary: [
            ParseClient.JSONResponseKeys.UniqueKey: UdacityClient.sharedInstance().userId!,
            ParseClient.JSONResponseKeys.ObjectId: "",
            ParseClient.JSONResponseKeys.FirstName: UdacityClient.sharedInstance().firstName!,
            ParseClient.JSONResponseKeys.LastName: UdacityClient.sharedInstance().lastName!,
            ParseClient.JSONResponseKeys.MapString: locationTitle,
            ParseClient.JSONResponseKeys.MediaUrl: urlTextField.text!,
            ParseClient.JSONResponseKeys.Latitude: latitude,
            ParseClient.JSONResponseKeys.Longitude: longitude
            ])

        ParseClient.sharedInstance().postStudentLocations(postLocation) { result, errorString in

            self.removeViewAsync(blockerView)
            if let err = errorString {
                self.displayError(err)
                return
            }
            self.completePost()
        }
   
    }

    @IBAction func cancelButtonTapped(sender: UIButton) {

        dismissViewControllerAnimated(false, completion: nil)
    }

    func completePost() {

        dispatch_async(dispatch_get_main_queue(), {

            guard let navCtrl = self.presentingViewController?.presentingViewController as? UINavigationController else {
                return
            }
            
            navCtrl.dismissViewControllerAnimated(true) {
                
                let alertCtrl = UIAlertController(title: "Notice", message: "You have successfully added your location!", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertCtrl.addAction(okAction)
                navCtrl.presentViewController(alertCtrl, animated: true, completion: nil)

                guard let tabbedCtrl = navCtrl.viewControllers[0] as? TabbedController else {
                    return
                }
                
                tabbedCtrl.refreshVcData()
            }
        })
    }
}

extension InformationPostingViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}