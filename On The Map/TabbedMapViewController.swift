//
//  TabbedMapViewController.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import MapKit

class TabbedMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        mapView.delegate = self

        reloadStudentAnnotations()
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadStudentAnnotations() {

        let blockerView = BlockerView(frame: view.frame)
        view.addSubview(blockerView)
        ParseClient.sharedInstance().getStudentLocations() { result, errorString in

            self.removeViewAsync(blockerView)

            let tabCtrl = self.tabBarController as! TabbedController
            tabCtrl.userExists = ParseClient.sharedInstance().userExists

            if let err = errorString {
                self.displayError(err)
                return
            }
            if let res = result {
                StudentData.data = res
                var annotations = [StudentMapAnnotation]()
                for r in StudentData.data {
                    annotations.append(r.mapAnnotation)
                }
                self.loadAnnotationsAsync(annotations)
            }
        }
    }

    func loadAnnotationsAsync(annotations: [MKAnnotation]) {

        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }

}

extension TabbedMapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if let annotation = annotation as? StudentMapAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! StudentMapAnnotation
        let url = NSURL(string: annotation.subtitle!)!
        UIApplication.sharedApplication().openURL(url)
        return
    }

}