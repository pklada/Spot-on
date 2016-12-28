//
//  AccountHelpers.swift
//  Spot
//
//  Created by Peter on 12/27/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import Firebase

class AccountHelpers: NSObject {

    static func signIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        AppState.sharedInstance.uid = user?.uid
        let notificationName = Notification.Name(rawValue: "onSignInCompleted")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
    }
    
    static func signOut() {
        AppState.sharedInstance.displayName = nil
        AppState.sharedInstance.photoURL = nil
        AppState.sharedInstance.signedIn = false
        AppState.sharedInstance.uid = nil
    }
    
    static func getCurrentUser() -> FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
}
