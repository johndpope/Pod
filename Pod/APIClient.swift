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

typealias JSONDictionary = [String: Any]

class APIClient {
    static var sharedInstance = APIClient()
    private var dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
    var userName: String?
    var userID: String?
    var profilePicture: UIImage?
    var geoHashCodes = [String]()
    
    struct Boundaries {
        var east: CLLocationDegrees?
        var north: CLLocationDegrees?
        var south: CLLocationDegrees?
        var west: CLLocationDegrees?
    }
    
    func getNearbyMapPods(location: CLLocationCoordinate2D, expanding: Bool, completion: @escaping ([PodList]?, Boundaries?) -> ()) {
        
        // Clear geohash codes if no expanding pod search
        if !expanding {
            geoHashCodes.removeAll()
        }
        
        // Construct request parameters
        let lat = location.latitude
        let long = location.longitude
        let httpMethodName = "POST"
        let URLString = "/Exploring_NeighborPodsConsecutiveExpansion"
        let queryStringParameters = ["lang": "en"]
        var geoCodes = [String: String]()
        for index in 0..<geoHashCodes.count {
            geoCodes[String(index)] = geoHashCodes[index]
        }
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "latitude": "\(lat)",
            "longitude": "\(long)",
            "length": "\(geoHashCodes.count)"
        ]
        let jsonObject: [String: AnyObject]  = ["GeoHashCode": geoCodes as AnyObject]
        
        // Construct the request object
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName,
                                              urlString: URLString,
                                              queryParameters: queryStringParameters,
                                              headerParameters: headerParameters,
                                              httpBody: jsonObject)
        
        // Invoke the request
        let invocationClient = AWSAPI_2PCJWD2UDJ_LambdaMicroserviceClient(forKey: AWSCloudLogicDefaultConfigurationKey)
        invocationClient.invoke(apiRequest).continueWith { (task: AWSTask<AWSAPIGatewayResponse>) -> Any? in
            
            // Check for error
            guard task.error == nil else {
                print("Error gettting nearby map pods: \(task.error!)")
                completion(nil, nil)
                return nil
            }
            
            // Check for data
            guard let data = task.result?.responseData,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? JSONDictionary else {
                    print("No response data")
                    completion(nil, nil)
                    return nil
            }
            
            print("----------")
            print("----------")
            print(dictionary)
            print("----------")
            print("----------")
            
            // Store geohash codes for potential pod search expansion
            if let geoCodes = dictionary["GeoHashCode"] as? JSONDictionary {
                print("GeoCodes: \(geoCodes)")
                
                for (_, code) in geoCodes {
                    if !self.geoHashCodes.contains(code as! String) {
                        self.geoHashCodes.append(code as! String)
                    }
                }
            }
            
            // Get boundaries
            var boundaries = Boundaries()
            if let bounds = dictionary["boundaries"] as? JSONDictionary,
                let east = bounds["e"] as? CLLocationDegrees,
                let north = bounds["n"] as? CLLocationDegrees,
                let south = bounds["s"] as? CLLocationDegrees,
                let west = bounds["w"] as? CLLocationDegrees {
                boundaries = Boundaries(east: east, north: north, south: south, west: west)
            }
            
            // Populate PodLists from response
            var nearbyPods = [PodList]()
            var index = 0
            while(dictionary[String(index)] != nil) {
                if let podData = dictionary[String(index)] as? JSONDictionary {
                    let pod = PodList()
                    pod?._podId = podData["PodId"] as? NSNumber
                    pod?._userIdList = podData["UserIdList"] as? [String]
                    pod?._isPrivate = podData["IsPrivate"] as? NSNumber
                    pod?._usernameList = podData["UserList"] as? [String]
                    pod?._name = podData["Name"] as? String
                    pod?._radius = podData["Radius"] as? NSNumber
                    pod?._geoHashCode = podData["GeoHash"] as? String
                    pod?._latitude = podData["Latitude"] as? NSNumber
                    pod?._longitude = podData["Longitude"] as? NSNumber
                    pod?._createdByUserId = podData["CreatedByUserId"] as? String
                    nearbyPods.append(pod!)
                } else {
                    print("Data at index \(index) could not be casted as a JSONDictionary")
                }
                
                index += 1
            }
            completion(nearbyPods, boundaries)
            
            return nil
        }
    }
    
    func getNearbyPods(location: CLLocationCoordinate2D, completion: @escaping ([PodList]?) ->()){
        let lat = location.latitude
        let long = location.longitude
        
        let httpMethodName = "POST"
        let URLString = "/Pod_GetNeighboringPods"
        let queryStringParameters = ["lang": "en"]
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Latitude":"\(lat)",
            "Longitude":"\(long)"
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
            
            // convert String to NSData
            let dict = self.convertToDictionary(text: responseString!)

            
            var nearbyPods: [PodList]? = []
            for(_, val) in dict! {
                if let curPod = val as? Dictionary<String, Any>{
                    let podName = curPod["Name"] as! String
                    let coordinates = CLLocationCoordinate2D(latitude: curPod["Latitude"] as! Double, longitude: curPod["Longitude"] as! Double)
                    // NOTE: gotta implement this
                    let radius = 5.0
                    let userIdList = curPod["UserIdList"] as! [String]
                    let podID = curPod["PodId"] as! Int
                    let isLocked = curPod["IsPrivate"] as! Bool
                    let userNameList = curPod["UserList"] as! [String]
                    let geoHash = curPod["GeoHash"] as! String
                    let pod = PodList()
                    let userID = curPod["CreatedByUserId"] as! String
                    pod?._podId = podID as NSNumber
                    pod?._userIdList = userIdList
                    pod?._isPrivate = isLocked as NSNumber
                    pod?._usernameList = userNameList
                    pod?._name = podName
                    pod?._radius = radius as NSNumber
                    pod?._geoHashCode = geoHash
                    pod?._latitude = coordinates.latitude as NSNumber
                    pod?._longitude = coordinates.longitude as NSNumber
                    pod?._createdByUserId = userID
                    nearbyPods?.append(pod!)
                }
                
            }
            completion(nearbyPods)
            
            return nil
        }
    }
    
    func savePod(location: CLLocationCoordinate2D, name: String, radius: Double, isPrivate: Bool){
        let lat = location.latitude
        let long = location.longitude
        
        let httpMethodName = "POST"
        let URLString = "/CreateNewPods"
        let queryStringParameters = ["lang": "en"]
        var isPrivateStr = "F"
        if isPrivate {
            isPrivateStr = "T"
        }
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "latitude":"\(lat)",
            "longitude":"\(long)",
            "name": "\(name)",
            "radius": "\(radius)",
            "isPrivate": isPrivateStr,
            "userId": "\(FacebookIdentityProfile._sharedInstance.userId!)",
            "userName": "\(FacebookIdentityProfile._sharedInstance.userName!)"
        ]
        print(headerParameters)
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

            print(responseString)


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
        post1?._numComments = 6
        post1?._postType = PostType.text.hashValue as NSNumber
        post1?._postContent = "What up its Chaz"
        post1?._postedDate = NSDate().timeIntervalSince1970 as NSNumber
        post1?._postPoll = ["none":1]
        post1?._postImage = "No Image"
        
        let post2 = Posts()
        post2?._posterName = "Chenye Zhu"
        post2?._podId = withId as NSNumber
        post2?._numComments = 9
        post2?._postType = PostType.text.hashValue as NSNumber
        post2?._postContent = "What up its Chenye ZHUUUUUUUUU"
        post2?._postedDate = NSDate().timeIntervalSince1970 as NSNumber
        post2?._postPoll = ["none":1]
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
        
    func getPostForPod(withId: Int, index: Int, completion: @escaping (_ posts: [Posts?], _ index: Int) ->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "PodId = :PodId"
        
        queryExpression.expressionAttributeValues = [":PodId" : withId ]
        dynamoDBObjectMapper .query(Posts.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion([], index)
                    } else {
                        completion(result.items as! [Posts], index)
                    }
                }
            }
            return nil
        })
    }
    
    func createNewPostForPod(withId: Int, post: Posts) {
        post.image = nil
        dynamoDBObjectMapper.save(post) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("post saved")
        }
    }
    
    func updatePostInfo(post: Posts){
        post.image = nil
        post.userImage = nil
        if (post._postLikes?.isEmpty)! {
            post._postLikes = nil
        }
        dynamoDBObjectMapper.save(post) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("post updated")
        }
    }
    
    func getPod(withId: Int, geoHash: String, completion: @escaping (_ pod: PodList?) ->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "GeoHashCode = :GeoHashCode AND PodId = :PodId"
        
        queryExpression.expressionAttributeValues = [":PodId" : withId, ":GeoHashCode": geoHash ]
        dynamoDBObjectMapper .query(PodList.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion(nil)
                    } else {
                        for r in result.items as! [PodList]{
                            completion(r)
                        }
                    }
                }
            }
            return nil
        })
    }
    
    func updatePod(pod: PodList){
//        if (pod.postData?.isEmpty)! {
//            pod.postData = nil
//        }

        dynamoDBObjectMapper.save(pod) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("pod updated")
        }
    }
    
    func createUser(withId: String, name: String, photoURL: String, profileURL: String, faecbookId: String){
        let userInfo = UserInformation()
        userInfo?._awsId = withId
        userInfo?._photoURL = photoURL
        userInfo?._username = name
        userInfo?._profileURL = profileURL
        userInfo?._facebookId = faecbookId
        dynamoDBObjectMapper.save(userInfo!) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("user information updated")
        }
    }
    
    func getUser(withId: String, completion: @escaping (_ pod: UserInformation?) ->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "facebookId = :facebookId"
        
        queryExpression.expressionAttributeValues = [":facebookId" : withId]
        dynamoDBObjectMapper .query(UserInformation.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion(nil)
                    } else {
                        for r in result.items as! [UserInformation]{
                            completion(r)
                        }
                    }
                }
            }
            return nil
        })
    }
    
    func createCommentForPost(withID: String, commentBody: String, completion: @escaping (_ comments: Comments?)->()){
        let comment = Comments()
        comment?._userId = FacebookIdentityProfile._sharedInstance.userId!
        comment?._photoURL = FacebookIdentityProfile._sharedInstance.imageURL?.absoluteString
        comment?._commentBody = commentBody
        comment?._postId = withID
        comment?._postDateGMT = NSDate().timeIntervalSince1970 as NSNumber
        dynamoDBObjectMapper.save(comment!) { (err) in
            if let error = err {
                print("Amazin DynamoDB Save Error: \(error)")
                return
            }
            print("comment saved")
            completion(comment)
        }
    }
    
    func getCommentsForPost(withId: String, completion: @escaping (_ comments: [Comments?])->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "postId = :postId"
        
        queryExpression.expressionAttributeValues = [":postId" : withId]
        dynamoDBObjectMapper .query(Comments.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion([])
                    } else {
                        completion(result.items as! [Comments])
                    }
                }
            }
            return nil
        })
    }
    
    func getUserPodIds(completion: @escaping (_ pods: [UserPods?])->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId= :userId"
        
        queryExpression.expressionAttributeValues = [":userId" : FacebookIdentityProfile._sharedInstance.userId!]
        dynamoDBObjectMapper .query(UserPods.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion([])
                    } else {
                        completion(result.items as! [UserPods])
                    }
                }
            }
            return nil
        })
    }

    
    func addPodToUsersList(podId: Int, geoHash: String){
        getUserPodIds { (pods) in
            let uPod = UserPods()
            uPod?._podId = podId as NSNumber
            uPod?._userId = FacebookIdentityProfile._sharedInstance.userId!
            uPod?._geoHash = geoHash
            self.dynamoDBObjectMapper.save(uPod!)
        }
    }
    
    func getPodRequestsForCurrentUser(completion: @escaping (_ requests: [PodRequests?])->()){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId= :userId"
        queryExpression.expressionAttributeValues = [":userId" : FacebookIdentityProfile._sharedInstance.userId!]
        dynamoDBObjectMapper .query(PodRequests.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count == 0 {
                        completion([])
                    } else {
                        completion(result.items as! [PodRequests])
                    }
                }
            }
            return nil
        })
    }
    

    
    func sendJoinRequest(pod: PodList){
        let request = PodRequests()
        request?._podId = pod._podId!
        request?._userId = pod._createdByUserId
        request?._sentBy = FacebookIdentityProfile._sharedInstance.userId!
        request?._requestId = UUID().uuidString
        request?._sendTime = NSDate().timeIntervalSince1970 as NSNumber
        request?._senderName = FacebookIdentityProfile._sharedInstance.userName!
        request?._geoHashCode = pod._geoHashCode
        request?._requestType = RequestType.join.hashValue as NSNumber
        dynamoDBObjectMapper.save(request!)
        print("join sent")
    }
    
    func removePossibleRequests(podId: Int){
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "userId= :userId AND podId= :podId"
        queryExpression.expressionAttributeValues = [":userId" : FacebookIdentityProfile._sharedInstance.userId!, ":podID":podId]
        dynamoDBObjectMapper .query(PodRequests.self, expression: queryExpression) .continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Error: \(error)")
            } else {
                if let result = task.result {//(task.result != nil) {
                    if result.items.count != 0 {
                        for pod in result.items as! [PodRequests]{
                            self.dynamoDBObjectMapper.remove(pod)
                        }
                    }
                }
            }
            return nil
        })
    }
    
    func sendInviteRequest(to: [UserInformation], podId: Int, podName: String, geoHash: String){
        for user in to {
            let request = PodRequests()
            request?._podId = podId as NSNumber
            request?._userId = user._facebookId
            request?._sentBy = FacebookIdentityProfile._sharedInstance.userId!
            request?._requestId = UUID().uuidString
            request?._sendTime = NSDate().timeIntervalSince1970 as NSNumber
            request?._senderName = FacebookIdentityProfile._sharedInstance.userName!
            request?._geoHashCode = geoHash
            request?._requestType = RequestType.invite.hashValue as NSNumber
            dynamoDBObjectMapper.save(request!)
            dynamoDBObjectMapper.save(request!, completionHandler: { (err) in
                if let error = err {
                    print("Amazin DynamoDB Save Error: \(error)")
                    return
                }
                print("request saved")
            })
        }
    }
    
    func acceptPodInvitation(request: PodRequests){
         print("Accept")
//        dynamoDBObjectMapper.remove(request)
//        let userPod = UserPods()
//        userPod?._userId = FacebookIdentityProfile._sharedInstance.userId!
//        userPod?._podId = request._podId
//        userPod?._geoHash = request._podGeoHash
//        dynamoDBObjectMapper.save(userPod!)
//        getPod(withId: request._podId as! Int, geoHash: request._podGeoHash!) { (pod) in
//            pod?._userIdList?.append(FacebookIdentityProfile._sharedInstance.userId!)
//            pod?._usernameList?.append(FacebookIdentityProfile._sharedInstance.userName!)
//            self.dynamoDBObjectMapper.save(pod!)
//        }
    }
    
    func declinePodInvitation(request: PodRequests){
        dynamoDBObjectMapper.remove(request)
    }
    
    func acceptJoinRequest(request: PodRequests){
//        dynamoDBObjectMapper.remove(request)
//        let userPod = UserPods()
//        userPod?._userId = FacebookIdentityProfile._sharedInstance.userId!
//        userPod?._podId = request._podId
//        userPod?._geoHash = request._podGeoHash
//        dynamoDBObjectMapper.save(userPod!)
//        getPod(withId: request._podId as! Int, geoHash: request._podGeoHash!) { (pod) in
//            pod?._userIdList?.append(FacebookIdentityProfile._sharedInstance.userId!)
//            pod?._usernameList?.append(FacebookIdentityProfile._sharedInstance.userName!)
//           
//
//            self.dynamoDBObjectMapper.save(pod!)
//        }
        print("accept join request. this isnt actually doing anything")
    }
    


}
