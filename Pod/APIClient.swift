//
//  APIClient.swift
//  Pod
//
//  Created by Max Freundlich on 5/25/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AWSAPIGateway
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import AWSFacebookSignIn
import AWSDynamoDB

class APIClient {
    static var sharedInstance = APIClient()
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    var userName: String?
    var userID: String?
    var profilePicture: UIImage?
    
    func getNearbyPods(location: CLLocationCoordinate2D, completion: @escaping ([Pod]?) ->()){
        let lat = location.latitude
        let long = location.longitude
        
        let httpMethodName = "POST"
        let URLString = "/Pod_GetNeighboringPods"
        let queryStringParameters = ["lang": "en"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Latitude":"37.4204870",
            "Longitude":"-122.1714210"
        ]
        let jsonObject: [String: AnyObject]  = ["Latitude": 37.4204870 as AnyObject, "Longitude": -122.1714210 as AnyObject]
        
        
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: jsonObject)
        
        let invocationClient = AWSAPI_2PCJWD2UDJ_LambdaMicroserviceClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            if let error = task.error {
                print("Error occurred: \(error)")
                // Handle error here
                return nil
            }
            
            // Handle successful result here
            let result = task.result!
            let responseString = String(data: result.responseData!, encoding: .utf8)
            
            //print(responseString!)
            // convert String to NSData
            let dict = self.convertToDictionary(text: responseString!)
            //            var podList: [PodStruct]? = []
            //
            //            for (_, val) in dict! {
            //                let curPod = val as! Dictionary<String, Any>
            //                print(curPod)
            //                //Create fake post details
            //                let arroyoContent = PostDetails(posterName: "Arroyo", postText: "Come to the lougne for the hosue meeting!", numHearts: 13, numComments: 4)
            //                let content = PostDetails(posterName: "Adad M.", postText: "Push me to the edge! All my friends are dead! Push me to the edge! all my friends are dead! 2017", numHearts: 26, numComments: 6)
            //                let photoContent = PostDetails(posterName: "Max Freundlich", photo: UIImage(named: "profile-pic")!, postText: "Check out this dank pic of me", numHearts: 100, numComments: 12)
            //                let pod = PodStruct(title: curPod["Name"] as! String, postData: [arroyoContent, content, photoContent])
            //                podList?.append(pod)
            //            }
            //            completion(podList)
            
            var nearbyPods: [Pod]? = []
            for(_, val) in dict! {
                let curPod = val as! Dictionary<String, Any>
                let podName = curPod["Name"] as! String
                let coordinates = CLLocationCoordinate2D(latitude: curPod["Latitude"] as! Double, longitude: curPod["Longitude"] as! Double)
                // NOTE: gotta implement this
                let radius = 5.0
                let userList = curPod["UserList"] as! [String]
                let numPeople = userList.count
                let podID = curPod["PodId"] as! Int
                let pod = Pod(podID: podID, name: podName, coordinates: coordinates, radius: radius, numPeople: numPeople, postData: [])
                nearbyPods?.append(pod)
            }
            completion(nearbyPods)
            
            
            
            
            return nil
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func initClientInfo(){
        let identityManager = AWSIdentityManager.default()
        
        if let identityUserName = identityManager.identityProfile?.userName {
            userName = identityUserName
        } else {
            userName = NSLocalizedString("Guest User", comment: "Placeholder text for the guest user.")
        }
        
        userID = identityManager.identityId
        if let imageURL = identityManager.identityProfile?.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                profilePicture = profileImage
            } else {
                profilePicture = UIImage(named: "UserIcon")
            }
        }
    }
    
    func getProfileImage() -> UIImage? {
        let identityManager = AWSIdentityManager.default()
        
        if let imageURL = identityManager.identityProfile?.imageURL {
            let imageData = try! Data(contentsOf: imageURL)
            if let profileImage = UIImage(data: imageData) {
                profilePicture = profileImage
                return profileImage
            } else {
                profilePicture = UIImage(named: "UserIcon")
                return UIImage(named: "UserIcon")!
            }
        } else {
            profilePicture = UIImage(named: "UserIcon")
            return UIImage(named: "UserIcon")!
        }
    }
    
    func uploadTestPostsToPod(withId: Int){
        let post1 = Posts()
        post1?._posterName = "Max Freundlich"
        post1?._podId = withId as NSNumber
        post1?._postId = UUID().uuidString
        post1?._numLikes = 10
        post1?._numComments = 6
        post1?._postType = PostType.text.hashValue as NSNumber
        post1?._postContent = "What up its Chaz"
        post1?._postedDate = NSDate().timeIntervalSince1970 as NSNumber
        post1?._postPoll = ["none":"none"]
        post1?._postImage = "No Image"
        
        let post2 = Posts()
        post2?._posterName = "Chenye Zhu"
        post2?._podId = withId as NSNumber
        post2?._postId = UUID().uuidString
        post2?._numLikes = 26
        post2?._numComments = 9
        post2?._postType = PostType.text.hashValue as NSNumber
        post2?._postContent = "What up its Chenye ZHUUUUUUUUU"
        post2?._postedDate = NSDate().timeIntervalSince1970 as NSNumber
        post2?._postPoll = ["none":"none"]
        post2?._postImage = "No Image"
        
        dynamoDBObjectMapper.save(post1!) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("post saved")
        }
        
        dynamoDBObjectMapper.save(post2!) { (err) in
            if let error = err {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("post saved")
        }
    }
    
    func getPostForPod(withId: Int, completion: @escaping (Posts?) ->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "PodId = :PodId"
        
        queryExpression.expressionAttributeValues = [":PodId" : withId ]
        dynamoDBObjectMapper .query(Posts.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion(nil)
                    } else {
                        for r in result.items as! [Posts]{
                            completion(r)
                        }
                    }
                }
            }
            return nil
        })
    }
    
    
}
