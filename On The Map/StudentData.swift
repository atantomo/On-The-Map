//
//  StudentData.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation
import MapKit

class StudentData: NSObject {

    static var data: [StudentInformation] = []
}

struct StudentInformation {

    var uniqueKey = ""
    var objectId = ""
    var firstName = ""
    var lastName = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mapString = ""
    var mediaURL = ""
    var mapAnnotation = StudentMapAnnotation!()

    init(dictionary: [String : AnyObject]) {

        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as! String
        objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as! String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaUrl] as! String
        mapAnnotation = StudentMapAnnotation(dictionary: dictionary)

    }
    
    static func locationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {

        var locations = [StudentInformation]()

        for result in results {
            locations.append(StudentInformation(dictionary: result))
        }

        return locations
    }

}

class StudentMapAnnotation: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(dictionary: [String : AnyObject]) {

        let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as! String
        let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as! String
        let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as! Double
        let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as! Double
        let mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaUrl] as! String

        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        title = firstName + " " + lastName
        subtitle = mediaURL
    }
}
