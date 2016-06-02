//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Andrew Tantomo on 2016/02/09.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

extension UdacityClient {

    struct Constants {
        static let BaseUrlSecure = "https://www.udacity.com/api/"
    }

    struct Methods {
        static let Session = "session"
        static let Users = "users/"
    }

    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }

    struct JSONResponseKeys {
        static let Account = "account"
        static let Key = "key"
        static let Session = "session"
        static let Id = "id"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}