//
//  ParseConstants.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/11.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

extension ParseClient {

    struct Constants {
        static let BaseUrlSecure = "https://api.parse.com/1/classes/"
        static let ApplicationId = "APP_ID_HERE"
        static let ApiKey = "API_KEY_HERE"
    }

    struct Methods {
        static let StudentLocation = "StudentLocation/"
    }

    struct JSONBodyKeys {

        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Limit = "limit"
        static let Order = "order"

    }

    struct JSONResponseKeys {

        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let Results = "results"


    }
}
