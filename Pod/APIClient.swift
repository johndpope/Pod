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

class APIClient {
    static var sharedInstance = APIClient()
    var userName: String?
    var userID: String?
    var profilePicture: UIImage?
    
    func getNearbyPods(location: CLLocationCoordinate2D, completion: @escaping () ->()){
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
            //print(dict)

            
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
    
}
