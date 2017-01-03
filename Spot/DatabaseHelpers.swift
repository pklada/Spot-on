//
//  DatabaseHelpers
//  Spot
//
//  Created by Peter on 12/28/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import Foundation
import Firebase

class DatabaseHelpers: NSObject {
    
    static let sharedInstance = DatabaseHelpers()
    
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle!
    var spots: [FIRDataSnapshot]! = []
    
    func configureDatabaseWithCallback(onDatabaseChange: @escaping ((AppState.SpotState) -> (Void))) {
        self.ref = FIRDatabase.database().reference()
        
        _refHandle = ref.child("spots").child("1").observe(FIRDataEventType.value, with: { (snapshot) in
            self.setStateByDatabaseValue(value: snapshot.value as! NSDictionary)
            onDatabaseChange(AppState.sharedInstance.spotState)
        })
    }
    
    func singleRefresh(onDatabaseRefresh: @escaping ((AppState.SpotState) -> (Void))) {
        ref.child("spots").child("1").observeSingleEvent(of: .value, with: { (snapshot) in
            self.setStateByDatabaseValue(value: snapshot.value as! NSDictionary)
            onDatabaseRefresh(AppState.sharedInstance.spotState)
        }) { (error) in
            //self.openLabel.text = error.localizedDescription
        }
    }
    
    func removeListener() {
        ref.child("spots").child("1").removeObserver(withHandle: _refHandle)
    }
    
    func setStateByDatabaseValue(value: NSDictionary) {
        let occupant = value["occupant"] as? String ?? ""
        let occupied = value["occupied"] as! Bool
        let occupantUid = value["occupant_uid"] as? String ?? ""
        let occupantDiplayImageUrl = value["occupant_display_image"] as? String ?? nil
        AppState.sharedInstance.occupied = occupied
        AppState.sharedInstance.occupantUid = occupantUid
        AppState.sharedInstance.occupant = occupant
        AppState.sharedInstance.occupantDisplayImageUrl = occupantDiplayImageUrl
        
        var state = AppState.SpotState.Open
        
        if occupied {
            if occupantUid == AppState.sharedInstance.uid {
                state = .Owned
            } else {
                state = .Occupied
            }
        } else {
            state = .Open
        }
        
        AppState.sharedInstance.spotState = state
    }
}
