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
    
    private lazy var googleSignInButton: GIDSignInButton = {
        GIDSignIn.sharedInstance().uiDelegate = self
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.style = .wide
        return googleSignInButton
    }()
    
    private lazy var fbLoginButton: FBSDKLoginButton = {
        let fbLoginButton = FBSDKLoginButton()
        return fbLoginButton
    }()
    
    // MARK: - LoginViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil {
            print("Already logged in")
        } else {
            print("Not logged in")
        }

        view.addSubview(googleSignInButton.usingAutolayout())
        view.addSubview(fbLoginButton.usingAutolayout())
        setupConstraints()
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Google Sign In Button
        NSLayoutConstraint.activate([
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50.0),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
            ])
        
        // FB Login Button
        NSLayoutConstraint.activate([
            fbLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fbLoginButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 30.0),
            fbLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30.0),
            fbLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0),
            ])
    }
}

// MARK: - GIDSignInUIDelegate

extension LoginViewController: GIDSignInUIDelegate {
    
}
