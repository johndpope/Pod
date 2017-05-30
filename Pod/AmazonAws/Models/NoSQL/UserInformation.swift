//
//  UserInformation.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import Foundation
import UIKit
import AWSDynamoDB

class UserInformation: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _photoURL: String?
    var _username: String?
    var _profileURL: String?
    
    class func dynamoDBTableName() -> String {

        return "pod-mobilehub-1901037061-UserInformation"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_photoURL" : "photoURL",
               "_username" : "username",
               "_profileURL" : "profileURL",
        ]
    }
}
