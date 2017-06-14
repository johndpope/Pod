//
//  PodData.swift
//  Pod
//
//  Created by Max Freundlich on 5/6/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

//class Pod {
//    let podID: Int
//    let name: String
//    let coordinates: CLLocationCoordinate2D
//    let radius: Double
//    let numPeople: Int
//    var postData: [Posts]
//    let isLocked: Bool
//    let userNameList: [String]
//    var userIdList: [String]
//    let geoHash: String
//    
//    init(podID: Int, name:String, coordinates: CLLocationCoordinate2D, radius: Double, numPeople: Int, postData: [Posts], isLocked: Bool, userNameList: [String], userIdList: [String], geoHash: String) {
//        self.podID = podID
//        self.name = name
//        self.coordinates = coordinates
//        self.radius = radius
//        self.numPeople = numPeople
//        self.postData = postData
//        self.isLocked = isLocked
//        self.userIdList = userIdList
//        self.userNameList = userNameList
//        self.geoHash = geoHash
//    }
//    
//}

enum PostType {
    case text
    case photo
    case poll
}

enum RequestType {
    case join
    case invite
}
