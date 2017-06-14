//
//  AppDelegate.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/5/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GooglePlaces
import GoogleMaps
import AWSCore
import AWSMobileHubHelper
import AWSFacebookSignIn
import AWSS3
import AWSCognitoIdentityProvider
import UserNotifications
import AWSCognito
import BSForegroundNotification


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ForegroundNotificationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // GMSPlacesClient.provideAPIKey(Constants.APIServices.GMSPlacesKey)
        GMSServices.provideAPIKey(Constants.APIServices.GMSMapKey)

        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:52f72125-90a0-42ed-b34e-4a5c8fbb0212")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
//
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
//                                                                identityPoolId:"us-west-2:37f10bab-da5c-4c0c-92dc-cff4dd54ff71")
//        
//        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
//        
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.default()
        
        // Create a record in a dataset and synchronize with the server
        var dataset = syncClient.openOrCreateDataset("myDataset")
        dataset.setString("myValue", forKey:"myKey")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
        // TODO: Change navigation bar color scheme
//        var navigationBarAppearace = UINavigationBar.appearance()
//        
//        navigationBarAppearace.tintColor = UIColor.YourNavigationButtonsColor()  // Back buttons and such
//        navigationBarAppearace.barTintColor = UIColor.YourBackgroundColor()  // Bar's background color
//        
//        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.YourTitleColor()]  // Title's text color
        registerForPushNotifications()
        
        return AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Store the completion handler.
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation]) || GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
//                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        NSNotificationCenter.defaultCenter().postNotificationName("CognitoPushNotification", object: userInfo)
//    })
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got notification")
        let notification = ForegroundNotification(userInfo: userInfo)
        
        ForegroundNotification.systemSoundID = 1004
        notification.delegate = self
        notification.presentNotification()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        let syncClient = AWSCognito.default()
        syncClient.registerDevice(deviceToken).continueWith(block: { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Unable to register device: " + (task.error?.localizedDescription)!)
                
            } else {
                print("Successfully registered device with id: \(task.result)")
            }
            return task
        })
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                guard granted else { return }
                UIApplication.shared.registerForRemoteNotifications()
                self.getNotificationSettings()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func foregroundRemoteNotificationWasTouched(with userInfo: [AnyHashable: Any]) {
        print("touched")
    }

}
