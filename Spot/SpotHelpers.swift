//
//  SpotHelpers.swift
//  Spot
//
//  Created by Peter on 2/7/18.
//  Copyright © 2018 Peter. All rights reserved.
//

import Foundation

class SpotHelpers: NSObject {
    func claimSpot(spotModel: SpotModelController) {
        var mdata = [String: Any]()
        mdata["occupant"] = spotModel.user.displayName
        mdata["occupied"] = true
        mdata["occupant_uid"] = spotModel.user.uid
        if let photoUrl = spotModel.user.photoURL {
            mdata["occupant_display_image"] = photoUrl.absoluteString
        }
        DatabaseHelpers.sharedInstance.ref.child("spots").child("1").setValue(mdata)
    }
    
    func relinquishSpot() {
        DatabaseHelpers.sharedInstance.ref.child("spots").child("1").setValue([
            "occupant": nil,
            "occupied": false,
            "occupant_uid": nil,
            "occupant_display_image": nil
            ])
    }
}
