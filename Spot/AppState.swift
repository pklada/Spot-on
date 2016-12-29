//
//  AppState.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import UIKit

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    enum SpotState {
        case Default
        case Checking
        case Open
        case Occupied
        case Owned
        case LoggedOut
    }
    
    var spotState: SpotState = .Default
    
    func setState(state: SpotState) {
        spotState = state
    }
    
    func getColorForState() -> UIColor {
        var color = UIColor()
        
        switch self.spotState {
        case .Open:
            color = Constants.Colors.green
        case .Occupied:
            color = Constants.Colors.red
        case .Owned:
            color = Constants.Colors.blue
        case .LoggedOut:
            color = UIColor.white
        default:
            color = UIColor.white
        }
        
        return color
    }
    
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
    var uid: String?
}
