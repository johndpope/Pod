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


class APIClient {
    
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
        let httpBody = "{ \n  \"Latitude\":\"\(37.4204870)\", \n  \"Longitude\":\"\(-122.1714210)\"}"
        let jsonObject: [String: AnyObject]  = ["Latitude": 37.4204870 as AnyObject, "Longitude": -122.1714210 as AnyObject]
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString) // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        
        
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
            print(result.statusCode)
            
            return nil
        }
    }
}
