//
//  FirstViewController.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import Firebase
import pop

class FirstViewController: UIViewController {
    
    @IBOutlet weak var openView: UIView!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var openViewLabel: UILabel!
    @IBOutlet weak var occupiedView: UIView!
    @IBOutlet weak var occupiedLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var occupantAvatarView: AvatarView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var openViewBgd: UIView!
    
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle!
    var spots: [FIRDataSnapshot]! = []
    var occupied: Bool? = nil
    var occupantUid: String? = nil
    var occupant: String? = nil
    var occupantDisplayImageUrl: String? = nil
    var spotState: SpotState = .Default
    var occupantSectionVisible: Bool = false
    
    enum SpotState {
        case Default
        case Checking
        case Open
        case Occupied
        case Owned
        case LoggedOut
    }
    
    enum OccupiedSectionAnimationDirection {
        case Initial
        case In
        case Out
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animateOccupantSection(direction: .Initial)
        self.initView()
        self.configureDatabase()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (AccountHelpers.getCurrentUser() != nil) {
            self.configureUIForState(state: .Checking)
        } else {
            self.configureUIForState(state: .LoggedOut)
        }
        
        if(AppState.sharedInstance.signedIn) {
            self.configureDatabase()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUIForState(state: SpotState) {
        switch state {
        case .Checking:
            self.openLabel.text = "Checking..."
            self.openViewLabel.text = ""
            self.emojiLabel.text = "🤔"
            self.openView.backgroundColor = UIColor.lightGray
            self.animateSpotForPending()
        case .Occupied:
            self.openView.backgroundColor = Constants.Colors.red
            self.openLabel.text = "Occupied. Darn."
            self.openLabel.textColor = Constants.Colors.red
            self.openViewLabel.text = ""
            self.occupiedLabel.text = occupant
            if let imgUrl = occupantDisplayImageUrl {
                self.occupantAvatarView.setImage(url: "\(imgUrl)")
            }
            self.emojiLabel.text = "☹️"
            self.emojiLabel.isHidden = false
            self.tabBarController?.tabBar.tintColor = Constants.Colors.red
            self.animateSpotForDefault()
            
        case .Open:
            self.openView.backgroundColor = Constants.Colors.green
            self.openLabel.textColor = Constants.Colors.green
            self.openLabel.text = "Open!"
            self.openViewLabel.text = "Claim spot?"
            self.openViewLabel.isHidden = false
            self.emojiLabel.text = ""
            self.tabBarController?.tabBar.tintColor = Constants.Colors.green
            self.animateSpotForDefault()
        case .Owned:
            self.openLabel.text = "You've got the spot."
            self.emojiLabel.isHidden = false
            self.emojiLabel.text = "👍"
            self.occupiedLabel.text = "You!"
            self.openView.backgroundColor = Constants.Colors.blue
            self.openLabel.textColor = Constants.Colors.blue
            self.openViewLabel.text = ""
            self.occupantAvatarView.setImage(url: "\(AppState.sharedInstance.photoURL!)")
            self.tabBarController?.tabBar.tintColor = Constants.Colors.blue
            self.animateSpotForDefault()
            
        case .LoggedOut:
            self.openLabel.text = "Hey! You need to login first!"
            self.emojiLabel.isHidden = true
            self.openLabel.textColor = UIColor.lightGray
            self.openViewLabel.isHidden = true
            self.openView.backgroundColor = UIColor.lightGray
            self.tabBarController?.tabBar.tintColor = UIColor.darkGray
            self.animateSpotForPending()
        default:
            self.openLabel.text = ""
            self.openViewLabel.text = ""
            self.emojiLabel.text = ""
            self.emojiLabel.isHidden = true
            self.openView.backgroundColor = UIColor.lightGray
            self.animateSpotForDefault()
        }
        
        self.spotState = state
        self.animateOccupantSection()
        self.configureBackgroundColor()
    }
    
    func initView () {
        if (AccountHelpers.getCurrentUser() != nil) {
            self.configureUIForState(state: .Checking)
        } else {
            self.configureUIForState(state: .LoggedOut)
        }
        self.openView.layer.cornerRadius = self.openView.frame.size.width / 2
        self.occupiedView.layer.cornerRadius = 3
        self.occupiedView.clipsToBounds = true
        
        self.openView.layer.shadowColor = UIColor.black.cgColor
        self.openView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.openView.layer.shadowRadius = 24
        self.openView.layer.shadowOpacity = 0.25
        
        let flagImage = UIImage(named: "ic_flag")?.withRenderingMode(.alwaysTemplate)
        self.flagImageView.image = flagImage
        self.flagImageView.tintColor = UIColor.white.withAlphaComponent(0.6)
        
        self.occupantAvatarView.setShadow(size: CGSize(width: 0, height: 1), opacity: 0.2, radius: 2)
        
        self.openViewBgd.layer.cornerRadius = self.openViewBgd.frame.size.width / 2
        
        self.view.backgroundColor = UIColor.clear
        
    }
    
    func readDatabaseValue(value: NSDictionary) {
        let occupant = value["occupant"] as? String ?? ""
        let occupied = value["occupied"] as! Bool
        let occupantUid = value["occupant_uid"] as? String ?? ""
        let occupantDiplayImageUrl = value["occupant_display_image"] as? String ?? nil
        self.occupied = occupied
        self.occupantUid = occupantUid
        self.occupant = occupant
        self.occupantDisplayImageUrl = occupantDiplayImageUrl
        
        var state = SpotState.Open
        
        if occupied {
            if occupantUid == AppState.sharedInstance.uid {
                state = SpotState.Owned
            } else {
                state = SpotState.Occupied
            }
        } else {
            state = SpotState.Open
        }
        
        self.configureUIForState(state: state)
    }
    
    func configureDatabase() {
        self.ref = FIRDatabase.database().reference()
        
        _refHandle = ref.child("spots").child("1").observe(FIRDataEventType.value, with: { (snapshot) in
            //let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.readDatabaseValue(value: snapshot.value as! NSDictionary)
        })
    }
    
    func singleRefresh() {
        self.configureUIForState(state: .Checking)
        
        ref.child("spots").child("1").observeSingleEvent(of: .value, with: { (snapshot) in
            self.readDatabaseValue(value: snapshot.value as! NSDictionary)
        }) { (error) in
            //self.openLabel.text = error.localizedDescription
        }
    }
    
    func relinquishSpot() {
        self.ref.child("spots").child("1").setValue([
            "occupant": nil,
            "occupied": false,
            "occupant_uid": nil,
            "occupant_display_image": nil
        ])
    }
    
    func claimSpot() {
        var mdata = [String: Any]()
        mdata["occupant"] = AppState.sharedInstance.displayName
        mdata["occupied"] = true
        mdata["occupant_uid"] = AppState.sharedInstance.uid
        if let photoUrl = AppState.sharedInstance.photoURL {
            mdata["occupant_display_image"] = photoUrl.absoluteString
        }
        print(mdata)
        self.ref.child("spots").child("1").setValue(mdata)
    }
    
    
    func openViewPressed() {
        
        if AccountHelpers.getCurrentUser() == nil {
            return
        }
        
        if let isOccupied = self.occupied {
            if (isOccupied && self.occupantUid == AppState.sharedInstance.uid) {
                relinquishSpot()
            } else if(isOccupied) {
                singleRefresh()
            } else {
                claimSpot()
            }
        } else {
            claimSpot()
        }
    }
    
    func animateOccupantSection(direction: OccupiedSectionAnimationDirection = .In) {
        var direction = direction
        let anim = POPSpringAnimation.init(propertyNamed: kPOPLayerTranslationY)
        let distance = self.occupiedView.frame.size.height + 16 + self.tabBarController!.tabBar.frame.size.height
        var key = String()
        
        if self.spotState == .Checking {
            return
        }
        
        if self.spotState == .Open || self.spotState == .LoggedOut {
            direction = .Out
        }
        
        if ((direction == .In && self.occupantSectionVisible) || (direction == .Out && !self.occupantSectionVisible)) {
            return
        }
        
        switch direction {
        case .Initial:
            anim?.toValue = distance
            anim?.fromValue = distance
            self.occupantSectionVisible = false
        case .In:
            anim?.fromValue = distance
            anim?.toValue = 0
            key = "moveIn"
            self.occupantSectionVisible = true
        case .Out:
            anim?.fromValue = 0
            anim?.toValue = distance
            key = "moveOut"
            self.occupantSectionVisible = false
        }
        
        anim?.springBounciness = 6
        anim?.springSpeed = 12
        self.occupiedView.layer.pop_add(anim, forKey: key)
    }
    
    func animateSpotForPending() {
        let anim = POPSpringAnimation.init(propertyNamed: kPOPViewScaleXY)
        anim?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        anim?.springBounciness = 0
        anim?.springSpeed = 20
        self.openView.pop_add(anim, forKey: "sizeDownPending")
    }
    
    func animateSpotForDefault() {
        self.openView.pop_removeAnimation(forKey: "sizeDownPending")
        
        let animExisting = self.openView.pop_animation(forKey: "sizeDown") as? POPSpringAnimation
        
        if (animExisting != nil) {
            animExisting?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
        } else {
            let anim = POPSpringAnimation.init(propertyNamed: kPOPViewScaleXY)
            anim?.toValue = NSValue(cgPoint: CGPoint(x: 1, y: 1))
            anim?.springBounciness = 12
            anim?.springSpeed = 20
            self.openView.pop_add(anim, forKey: "sizeup")
        }
    }

    
    func configureBackgroundColor() {
        var color = UIColor()
        var ringColor = UIColor()
        var bgdColor = UIColor()
        var alertBgdColor = UIColor()
        
        switch self.spotState {
        case .Open:
            color = Constants.Colors.green
        case .Occupied:
            color = Constants.Colors.red
        case .Owned:
            color = Constants.Colors.blue
        default:
            color = UIColor.white
        }

        bgdColor = UIColor.blend(color1: color, intensity1: 0.1, color2: UIColor.white, intensity2: 1)
        ringColor = UIColor.blend(color1: color, intensity1: 0.2, color2: UIColor.white, intensity2: 1)
        alertBgdColor = UIColor.blend(color1: color, intensity1: 0.15, color2: Constants.Colors.darkGray, intensity2: 1)
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options:.curveEaseInOut, animations: {
            self.openViewBgd.backgroundColor = UIColor.clear
            self.openViewBgd.layer.borderColor = ringColor.cgColor
            self.openViewBgd.layer.borderWidth = 2
            self.occupiedView.backgroundColor = alertBgdColor
            self.parent?.view.backgroundColor = bgdColor
        }, completion:nil)
    }
    
    func animateRing() {
        // check if it exists already
        let animExisting = self.openViewBgd.pop_animation(forKey: "ringSizeUp") as? POPDecayAnimation
        if animExisting != nil {
            return
        }
        
        let anim = POPDecayAnimation.init(propertyNamed: kPOPViewScaleXY)
        //anim?.toValue = NSValue(cgPoint: CGPoint(x: 1.08, y: 1.08))
        anim?.velocity = CGSize(width: 2, height: 2)
        let duration = anim?.duration
        self.openViewBgd.pop_add(anim, forKey: "ringSizeUp")
        
        UIView.animate(withDuration: duration!, delay: 0, options:.curveLinear, animations: {
            self.openViewBgd.alpha = 0
        }, completion: { finished in
            self.returnRing()
        })
    }
    
    func returnRing() {
        self.openViewBgd.pop_removeAllAnimations()
        self.openViewBgd.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear, animations: {
            self.openViewBgd.alpha = 1
        })
    }
    
    @IBAction func openViewTapped() {
        openViewPressed()
    }
    
    @IBAction func openViewTouchUp() {
        if AccountHelpers.getCurrentUser() == nil {
            return
        }
        
        self.animateSpotForDefault()
        self.animateRing()
    }
    
    @IBAction func openViewTouchedDown() {
        if AccountHelpers.getCurrentUser() == nil {
            return
        }
        
        let anim = POPSpringAnimation.init(propertyNamed: kPOPViewScaleXY)
        anim?.toValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
        anim?.springBounciness = 12
        anim?.springSpeed = 20
        self.openView.pop_add(anim, forKey: "sizeDown")
    }
}

