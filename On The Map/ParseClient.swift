//
//  ParseClient.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    var session: NSURLSession
    var objectId: String? = nil
    var userExists: Bool {
        return objectId != nil
    }

    // for queries
    var fetchLimit = "100"
    var fetchSort = "-updatedAt"

    override init() {
        
        session = NSURLSession.sharedSession()
        super.init()
    }

    class func sharedInstance() -> ParseClient {

        struct Singleton {
            static var sharedInstance = ParseClient()
        }

        return Singleton.sharedInstance
    }

    func taskForGETMethod(method: String, params: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let urlString = Constants.BaseUrlSecure + method + escapedParameters(params)
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        setCredentialsToRequest(request)

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForGETMethod", completionHandler: completionHandler)
        }
        task.resume()

        return task
    }

    func taskForPOSTMethod(method: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let urlString = Constants.BaseUrlSecure + method
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createJSONDataFromObj(jsonBody)!
        setCredentialsToRequest(request)

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForPOSTMethod", completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }

    func taskForPUTMethod(method: String, param: String, jsonBody: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let escapedParam = param.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        let urlString = Constants.BaseUrlSecure + method + escapedParam
        let url = NSURL(string: urlString)!

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = createJSONDataFromObj(jsonBody)!
        setCredentialsToRequest(request)

        let task = session.dataTaskWithRequest(request) { data, response, error in

            self.handleRequestData(data, response: response, error: error, domain: "taskForPUTMethod", completionHandler: completionHandler)
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

        var parsedData = NSDictionary()
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Failed parsing JSON data"]
            completionHandler(result: nil, error: NSError(domain: domain, code: Error.Exception.rawValue, userInfo: userInfo))
            return
        }

        completionHandler(result: parsedData, error: nil)
    }

    private func setCredentialsToRequest(request: NSMutableURLRequest) {

        request.addValue(Constants.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    }

    private func escapedParameters(parameters: [String : AnyObject]) -> String {

        var urlVars = [String]()

        for (key, value) in parameters {

            let stringValue = String(value)
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            urlVars += [key + "=" + escapedValue!]

        }

        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    private func createJSONDataFromObj(obj: [String : AnyObject]) -> NSData? {
        
        do {
            return try NSJSONSerialization.dataWithJSONObject(obj, options: .PrettyPrinted)
        } catch {
            print("error creating json data")
            return nil
        }
    }

}
