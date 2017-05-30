//
//  Posts.swift
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

class Posts: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _podId: NSNumber?
    var _postedDate: NSNumber?
    var _numComments: NSNumber?
    var _numLikes: NSNumber?
    var _postContent: String?
    var _postId: String?
    var _postImage: String?
    var _postPoll: [String: String]?
    var _postType: NSNumber?
    var _posterName: String?
    var _posterImageURL: String?
    class func dynamoDBTableName() -> String {

        return "pod-mobilehub-1901037061-Posts"
    }
    
    class func hashKeyAttribute() -> String {

        return "_podId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_postedDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_podId" : "PodId",
               "_postedDate" : "PostedDate",
               "_numComments" : "NumComments",
               "_numLikes" : "NumLikes",
               "_postContent" : "PostContent",
               "_postId" : "PostId",
               "_postImage" : "PostImage",
               "_postPoll" : "PostPoll",
               "_postType" : "PostType",
               "_posterName" : "PosterName",
               "_posterImageURL" : "PosterImageURL",
        ]
    }
}
