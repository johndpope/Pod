//
//  SignInViewController.swift
//  Pod
//
//  Created by Max Freundlich on 5/24/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSFacebookSignIn
import FBSDKLoginKit


class SignInViewController: UIViewController {

    @IBOutlet weak var facebookButton: AWSFacebookSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Facebook login permission scopes before the user logs in. Additional permissions can added here if desired.
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"])
        
        // Set button style large to show the text "Continue with Facebook"
        // use the label property named "providerText" to format the text or change the content
        facebookButton.buttonStyle = .large
        
        // Set the button sign in delegate to handle feedback from sign in attempt
        facebookButton.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SignInViewController: AWSSignInDelegate {
    
    func onLogin(signInProvider: AWSSignInProvider,
                 result: Any?,
                 authState: AWSIdentityManagerAuthState,
                 error: Error?) {
        if result != nil {
            APIClient.sharedInstance.initClientInfo()
            self.performSegue(withIdentifier: "toMainView", sender: nil)
            // handle success here
//            AWSFacebookSignInProvider.sharedInstance().login({ (result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
//                if error == nil {
//                    print(AWSIdentityManager.default().identityId!)
//                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
//                    return
//                }
//            })
//            AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName, completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
//                print("result = \(result), error = \(error)")
//                // If no error reported by SignInProvider, discard the sign-in view controller.
//                if error == nil {
//                    print(AWSIdentityManager.default().identityId!)
//                    self.performSegue(withIdentifier: "toTabBar", sender: nil)
//                    return
//                }
//            })
        } else {
            // handle error here
        }
    }
}

