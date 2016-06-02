//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/09.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit
import Foundation


extension UdacityClient {

    func login(channel: String, params: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {

        createAuthData(channel, params: params) { success, authData, errorString in

            if success {
                self.sessionId = authData!.sessionId
                self.userId = authData!.userId

                self.getPublicDataFromUserId(self.userId!) { success, publicData, errorString in

                    if success {
                        self.firstName = publicData!.firstName
                        self.lastName = publicData!.lastName
                    }
                    completionHandler(success: success, errorString: errorString)
                }

            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }

    }

    private func createAuthData(channel: String, params: [String : AnyObject], completionHandler: (success: Bool, authData: (sessionId: String, userId: String)?, errorString: String?) -> Void) {

        taskForPOSTMethod(Methods.Session, channel: channel, params: params) { result, error in
            if let error = error {

                var errorString = error.localizedDescription

                if (error.code != Error.Exception.rawValue) {
                    let errorCode = Error(rawValue: error.code)!
                    switch errorCode {
                    case .BadRequest:
                        errorString = "Did not specify exactly one credential"
                    case .Forbidden:
                        errorString = "Username and/or password doesn't match"
                    default:
                        errorString = "An unknown error has occurred"
                    }
                }

                completionHandler(success: false, authData: nil, errorString: errorString)
            } else {
                guard let sessId = result[JSONResponseKeys.Session]?![JSONResponseKeys.Id] as? String else {
                    completionHandler(success: false, authData: nil, errorString: "Could not find session id in data")
                    return
                }
                guard let usrId = result[JSONResponseKeys.Account]?![JSONResponseKeys.Key] as? String else {
                    completionHandler(success: false, authData: nil, errorString: "Could not find account key in data")
                    return
                }
                completionHandler(success: true, authData: (sessionId: sessId, userId: usrId), errorString: nil)
            }
        }
    }

    private func getPublicDataFromUserId(id: String, completionHandler: (success: Bool, publicData: (firstName: String, lastName: String)?, errorString: String?) -> Void) {

        taskForGETMethod(Methods.Users, param: id) { result, error in
            if let error = error {

                var errorString = error.localizedDescription

                if (error.code != Error.Exception.rawValue) {
                    let errorCode = Error(rawValue: error.code)!
                    switch errorCode {
                    case .NotFound:
                        errorString = "User not found"
                    default:
                        errorString = "An unknown error has occurred"
                    }
                }

                completionHandler(success: false, publicData: nil, errorString: errorString)
            } else {
                guard let firstName = result[JSONResponseKeys.User]?![JSONResponseKeys.FirstName] as? String else {
                    completionHandler(success: false, publicData: nil, errorString: "Could not find first name in data")
                    return
                }
                guard let lastName = result[JSONResponseKeys.User]?![JSONResponseKeys.LastName] as? String else {
                    completionHandler(success: false, publicData: nil, errorString: "Could not find last name in data")
                    return
                }
                completionHandler(success: true, publicData: (firstName: firstName, lastName: lastName), errorString: nil)
            }
        }
    }

    func logout(completionHandler: (success: Bool, errorString: String?) -> Void) {

        taskForDELETEMethod("session") { result, error in
            if let error = error {

                var errorString = error.localizedDescription

                if (error.code != Error.Exception.rawValue) {
                    errorString = "An unknown error has occurred"
                }

                completionHandler(success: false, errorString: errorString)
            } else {
                completionHandler(success: true, errorString: nil)
            }

        }
    }

}