//
//  SpotModel.swift
//  Spot
//
//  Created by Peter on 2/12/18.
//  Copyright © 2018 Peter. All rights reserved.
//

import Foundation

enum SpotState {
    case Default
    case Checking
    case Open
    case Occupied
    case Owned
    case NoAuth
}

struct Spot {
    var state: SpotState
    var occupied: Bool
    var occupant: String
    var occupantDisplayImageUrl: String?
    var occupantUid: String
}

struct User {
    var signedIn: Bool
    var displayName: String?
    var photoURL: URL?
    var uid: String?
}

class SpotModelController {
    var spot = Spot(state: .Default, occupied: false, occupant: "", occupantDisplayImageUrl: nil, occupantUid: "")
    
    var user = User(signedIn: false, displayName: nil, photoURL: URL(string:""), uid: nil)
}
