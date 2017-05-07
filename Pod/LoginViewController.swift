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
        GIDSignIn.sharedInstance().delegate = self
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.style = .wide
        return googleSignInButton
    }()
    
    private lazy var fbLoginButton: FBSDKLoginButton = {
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        return fbLoginButton
    }()
    
    // MARK: - LoginViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(googleSignInButton.usingAutolayout())
        view.addSubview(fbLoginButton.usingAutolayout())
        setupConstraints()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if GIDSignIn.sharedInstance().hasAuthInKeychain() || FBSDKAccessToken.current() != nil {
//            performSegue(withIdentifier: "toPodList", sender: nil)
//        }
//    }
    
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

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print("There was an error signing in with Google: \(error.localizedDescription)")
            return
        }
        performSegue(withIdentifier: "toPodList", sender: nil)
        
        // Perform any operations on signed in user here
        //let userId = user.userID                    // For client-side use only
        //let idToken = user.authentication.idToken   // Safe to send to the server
        //let fullName = user.profile.name
        //let givenName = user.profile.givenName
        //let familyName = user.profile.familyName
        //let email = user.profile.email
    }
    
}

// MARK: - FBSDKLoginButtonDelegate

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard error == nil else {
            print("There was an error loggin in with Facebook: \(error.localizedDescription)")
            return
        }
        performSegue(withIdentifier: "toPodList", sender: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Not needed. Will perform logout from a different VC
    }
}
