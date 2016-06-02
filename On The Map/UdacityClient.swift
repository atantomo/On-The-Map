//
//  UdacityClient.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/09.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    var session: NSURLSession

    var sessionId: String? = nil
    var userId: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil

    override init() {
        
        session = NSURLSession.sharedSession()
        super.init()
    }

    class func sharedInstance() -> UdacityClient {

        struct Singleton {
            static var sharedInstance = UdacityClient()
        }

        return Singleton.sharedInstance
    }

    func taskForGETMethod(method: String, param: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let escapedParam = param.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        let urlString = Constants.BaseUrlSecure + method + escapedParam
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForGETMethod", completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }

    func taskForPOSTMethod(method: String, channel: String, params: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let urlString = Constants.BaseUrlSecure + method
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = createJSONDataFromObj(params, channel: channel)!

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForPOSTMethod", completionHandler: completionHandler)
        }
        task.resume()

        return task
    }

    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let urlString = Constants.BaseUrlSecure + method
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"

        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForDELETEMethod", completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }

    private func handleRequestData(data: NSData?, response: NSURLResponse?, error: NSError?, domain: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        guard error == nil else {
            print("Request returned an error: \(error)")
            let userInfo = [NSLocalizedDescriptionKey : "Connection could not be established"]
            completionHandler(result: nil, error: NSError(domain: domain, code: Error.Exception.rawValue, userInfo: userInfo))
            return
        }

        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where
            statusCode >= 200 && statusCode <= 299 else {

                var err: Error
                if let response = response as? NSHTTPURLResponse {
                    print("Request returned status code: \(response.statusCode)")

                    switch response.statusCode {
                    case 400:
                        err = Error.BadRequest
                    case 403:
                        err = Error.Forbidden
                    case 404:
                        err = Error.NotFound
                    default:
                        err = Error.Unknown
                    }
                } else {
                    print("Request returned invalid response: \(response)")
                    err = Error.Unknown
                }
                completionHandler(result: nil, error: NSError(domain: domain, code: err.rawValue, userInfo: nil))
                return
        }

        guard let data = data else {
            let userInfo = [NSLocalizedDescriptionKey : "Request returned no data"]
            completionHandler(result: nil, error: NSError(domain: domain, code: Error.Exception.rawValue, userInfo: userInfo))
            return
        }

        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

        var parsedData = NSDictionary()
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! NSDictionary
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Failed parsing JSON data"]
            completionHandler(result: nil, error: NSError(domain: domain, code: Error.Exception.rawValue, userInfo: userInfo))
            return
        }

        completionHandler(result: parsedData, error: nil)
    }

    private func createJSONDataFromObj(obj: [String : AnyObject], channel: String) -> NSData? {

        let object = [channel : obj]
        do {
            return try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        } catch {
            print("error creating json data")
            return nil
        }
    }
}