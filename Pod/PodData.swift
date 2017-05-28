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

class Pod {
    let name: String
    let coordinates: CLLocationCoordinate2D
    let radius: Double
    let numPeople: Int
    
    init(name:String, coordinates: CLLocationCoordinate2D, radius: Double, numPeople: Int) {
        self.name = name
        self.coordinates = coordinates
        self.radius = radius
        self.numPeople = numPeople
    }
    
}

func getTestData() -> [Pod] {
    var arr = [Pod]();
    var coordinates = CLLocationCoordinate2D(latitude: 37.420487, longitude: -122.171421)
    var p1 = Pod(name: "680 Lomita Pod", coordinates: coordinates, radius: 100, numPeople: 9)
    arr.append(p1)
    coordinates = CLLocationCoordinate2D(latitude: 37.425076, longitude: -122.170186)
    p1 = Pod(name: "Old Union Pod", coordinates: coordinates, radius: 100, numPeople: 15)
    arr.append(p1)
    coordinates = CLLocationCoordinate2D(latitude: 37.424305, longitude: -122.170842)
    p1 = Pod(name: "Tressider Pod", coordinates: coordinates, radius: 100, numPeople: 43)
    arr.append(p1)
    return arr
}

enum PostType {
    case text
    case photo
    case poll
}

class PostDetails {
    var posterName: String?
    var postText: String?
    var numHearts: Int?
    var numComments: Int?
    var postType: PostType?
    var postPhoto: UIImage?
    
    init(posterName: String, postText: String, numHearts: Int, numComments: Int) {
        self.postText = postText
        self.posterName = posterName
        self.numComments = numComments
        self.numHearts = numHearts
        self.postType = PostType.text
    }
    
    init(posterName: String, photo: UIImage, postText: String, numHearts: Int, numComments: Int){
        self.postText = postText
        self.posterName = posterName
        self.numComments = numComments
        self.numHearts = numHearts
        self.postType = PostType.photo
        self.postPhoto = photo
    }
}

class PodStruct {
    var title: String?
    var postData: [PostDetails?]
    
    init(title: String, postData: [PostDetails]) {
        self.title = title
        self.postData = postData
    }
    
    
}
