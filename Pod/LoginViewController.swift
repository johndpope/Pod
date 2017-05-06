//
//  LoginViewController.swift
//  Pod
//
//  Created by Michael-Anthony Doshi on 5/5/17.
//  Copyright © 2017 cs194. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var fbLoginButton: FBSDKLoginButton = {
        let fbLoginButton = FBSDKLoginButton()
        return fbLoginButton
    }()
    
    private lazy var googleSignInButton: GIDSignInButton = {
        let googleSignInButton = GIDSignInButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = .wide
        return googleSignInButton
    }()
    
    // MARK: - LoginViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil {
            print("Already logged in")
        } else {
            print("Not logged in")
        }

        view.addSubview(fbLoginButton)
        view.addSubview(googleSignInButton)
    }
}

// MARK: - GIDSignInUIDelegate

extension LoginViewController: GIDSignInUIDelegate {
    
}
