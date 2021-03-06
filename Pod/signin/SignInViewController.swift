//
//  SignInViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//
//

import UIKit
import AWSMobileHubHelper
import FBSDKLoginKit
import AWSFacebookSignIn

class SignInViewController : UIViewController {
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!

    
    var canCancel : Bool = true
    var didCompleteSignIn: ((_ success: Bool) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightBlue
        // set up the navigation controller
        self.setUpNavigationController()
        // set up the logo in image view
        self.setUpLogo()
        // set up facebook button if enabled
        self.setUpFacebookButton()
    }
    func setUpLogo() {
        logoView.image = UIImage(imageLiteralResourceName: "Logo+name")
        self.view.layoutIfNeeded()
    }

    
    func setUpFacebookButton() {
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile", "email", "user_friends"])
        // Facebook UI Setup
        let facebookComponent = AWSFacebookSignInButton(frame: CGRect(x: 0, y: 0, width: facebookButton.frame.size.width, height: facebookButton.frame.size.height))
        facebookComponent.buttonStyle = .large // use the large button style
        facebookComponent.delegate = self // set delegate to respond to user actions
        facebookButton.addSubview(facebookComponent)
    }
    
    func setUpNavigationController() {
        // set up title bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func barButtonClosePressed() {
        self.dismiss(animated: true, completion: nil)
        if let didCompleteSignIn = self.didCompleteSignIn {
            didCompleteSignIn(false)
        }
    }
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName, completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
            print("result = \(result), error = \(error)")
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                    if let didCompleteSignIn = self.didCompleteSignIn {
                        didCompleteSignIn(true)
                    }
                })   
                return
            }
            self.showErrorDialog(signInProvider.identityProviderName, withError: error as! NSError)
        })
    }
    
    func showErrorDialog(_ loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Sign-in Provider Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Label to cancel sign-in failure."), style: .cancel, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension SignInViewController: AWSSignInDelegate {
    // delegate handler for facebook / google sign in.
    func onLogin(signInProvider: AWSSignInProvider, result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) {
        // dismiss view controller if no error
        if error == nil {
            print("Signed in with: \(signInProvider)")
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            if let didCompleteSignIn = self.didCompleteSignIn {
                didCompleteSignIn(true)
            }
            return
        }
        self.showErrorDialog(signInProvider.identityProviderName, withError: error as! NSError)
    }
}
