//
//  SecondViewController.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SecondViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var infoLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.attemptSignIn();
        self.configureUI()
    }

    
    func attemptSignIn(forward: Bool = false) {
        if let user = AccountHelpers.getCurrentUser() {
            self.signedIn(user)
        } else if forward {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    @IBAction func signOutButtonPressed() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            GIDSignIn.sharedInstance().signOut()
            self.signedOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func configureUI() {
        if(AppState.sharedInstance.signedIn) {
            self.signInButton.alpha = 0
            self.signOutButton.alpha = 1
            self.infoLabel.text = "👋"
            
            self.mainLabel.text = "Hello, \(AppState.sharedInstance.displayName!)"
            if ((AppState.sharedInstance.photoURL) != nil) {
                self.avatarView.isHidden = false
                self.avatarView.setImage(url: "\(AppState.sharedInstance.photoURL!)")
                self.avatarView.setShadow()
            }
            
        } else {
            self.signInButton.alpha = 1
            self.signOutButton.alpha = 0
            self.mainLabel.text = "Sign in"
            self.avatarView.isHidden = true
            self.infoLabel.text = "Sign in to claim the spot!"
        }
        
        self.view.backgroundColor = UIColor.clear
        self.signOutButton.tintColor = Constants.Colors.blue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signedOut() {
        AccountHelpers.signOut()
        self.configureUI()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                return
            }
            
            self.signedIn(user)
        }
    
    }
    
    func signedIn(_ user: FIRUser?) {
        AccountHelpers.signIn(user)
        self.configureUI()
    }
     

}

