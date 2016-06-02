//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient {

    func getStudentLocations(completionHandler: (result: [StudentInformation]?, errorString: String?) -> Void) {

        let params = [
            JSONBodyKeys.Limit : fetchLimit,
            JSONBodyKeys.Order : fetchSort
        ]

        taskForGETMethod(Methods.StudentLocation, params: params) { jsonResult, error in
            if let error = error {

                var errorString = error.localizedDescription

                if (error.code != Error.Exception.rawValue) {
                    errorString = "An unknown error has occurred"
                }

                completionHandler(result: nil, errorString: errorString)
            } else {
                guard let results = jsonResult[JSONResponseKeys.Results] as? [[String : AnyObject]] else {
                    completionHandler(result: nil, errorString: "Could not find results key in data")
                    return
                }

                self.objectId = nil
                let currentUserId = UdacityClient.sharedInstance().userId!
                for i in 0 ..< results.count where self.objectId == nil {
                    guard let listUserId = results[i][JSONResponseKeys.UniqueKey] as? String else {
                        break
                    }
                    if currentUserId == listUserId {
                        self.objectId = results[i][JSONResponseKeys.ObjectId] as? String
                    }
                }
                
                let locations = StudentInformation.locationFromResults(results)
                completionHandler(result: locations, errorString: nil)
            }
        }
    }

    

    func postStudentLocations(location: StudentInformation, completionHandler: (result: String?, errorString: String?) -> Void) {

        let jsonBody: [String : AnyObject] = [
            JSONResponseKeys.UniqueKey: location.uniqueKey,
            JSONResponseKeys.FirstName: location.firstName,
            JSONResponseKeys.LastName: location.lastName,
            JSONResponseKeys.MapString: location.mapString,
            JSONResponseKeys.MediaUrl: location.mediaURL,
            JSONResponseKeys.Latitude: location.latitude,
            JSONResponseKeys.Longitude: location.longitude
        ]

        if objectId == nil {

            // If user data could not be found on the list, add new location
            taskForPOSTMethod(Methods.StudentLocation, jsonBody: jsonBody) { jsonResult, error in
                if let error = error {

                    var errorString = error.localizedDescription

                    if (error.code != Error.Exception.rawValue) {
                        errorString = "An unknown error has occurred"
                    }
                    
                    completionHandler(result: nil, errorString: errorString)
                } else {
                    guard let objId = jsonResult[JSONResponseKeys.ObjectId] as? String  else {
                        completionHandler(result: nil, errorString: "Could not find object id key in data")
                        return
                    }
                    completionHandler(result: objId, errorString: nil)
                }
            }
        } else {

            // Otherwise, overwrite previous location
            taskForPUTMethod(Methods.StudentLocation, param: objectId!, jsonBody: jsonBody) { jsonResult, error in
                if let error = error {

                    var errorString = error.localizedDescription

                    if (error.code != Error.Exception.rawValue) {
                        errorString = "An unknown error has occurred"
                    }

                    completionHandler(result: nil, errorString: errorString)
                } else {
                    guard let updTime = jsonResult[JSONResponseKeys.UpdatedAt] as? String  else {
                        completionHandler(result: nil, errorString: "Could not find update time key in data")
                        return
                    }
                    completionHandler(result: updTime, errorString: nil)
                }
            }
        }
    }

}