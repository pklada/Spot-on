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

    static func signIn(_ user: FIRUser?, spotModel: SpotModelController) {
        MeasurementHelper.sendLoginEvent()
        spotModel.user.displayName = user?.displayName ?? (user?.email)!
        spotModel.user.photoURL = user?.photoURL
        spotModel.user.signedIn = true
        spotModel.user.uid = (user?.uid)!
        
        let notificationName = Notification.Name(rawValue: "onSignInCompleted")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
    }
    
    static func signOut(spotModel: SpotModelController) {        
        spotModel.user.displayName = nil
        spotModel.user.photoURL = nil
        spotModel.user.signedIn = false
        spotModel.user.uid = nil
        spotModel.spot.state = .NoAuth
    }
    
    static func getCurrentUser() -> FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
}
