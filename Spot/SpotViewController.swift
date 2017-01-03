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
    
    var occupiedViewVisible: Bool!
    
    enum OccupiedSectionAnimationDirection {
        case In
        case Out
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DatabaseHelpers.sharedInstance.configureDatabaseWithCallback(onDatabaseChange: {state in
            self.configureUIForState(state: state)
        })
        
        if (AccountHelpers.getCurrentUser() != nil) {
            self.configureUIForState(state: .Checking)
        } else {
            self.configureUIForState(state: .NoAuth)
        }
        
        if(AppState.sharedInstance.signedIn) {
            self.singleRefresh()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DatabaseHelpers.sharedInstance.removeListener()
        
    }
    
    deinit {
        DatabaseHelpers.sharedInstance.removeListener()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func configureUIForState(state: AppState.SpotState) {
        let currentState = AppState.sharedInstance.spotState
        let desiredState = state
        
        switch state {
        case .Checking:
            self.openLabel.text = "Checking..."
            self.openViewLabel.text = ""
            self.emojiLabel.isHidden = false
            self.emojiLabel.text = "🤔"
            self.openView.backgroundColor = UIColor.lightGray
            self.animateSpotForPending()
        case .Occupied:
            self.openView.backgroundColor = Constants.Colors.red
            self.openLabel.text = "Occupied. Darn."
            self.openLabel.textColor = Constants.Colors.red
            self.openViewLabel.text = ""
            self.occupiedLabel.text = AppState.sharedInstance.occupant
            if let imgUrl = AppState.sharedInstance.occupantDisplayImageUrl {
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
            
        case .NoAuth:
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
        
        AppState.sharedInstance.setState(state: state)
        self.animateOccupantSection(desiredState: desiredState, currentState: currentState)
        self.configureUIColors()
    }
    
    func initView () {
        if (AccountHelpers.getCurrentUser() != nil) {
            self.configureUIForState(state: .Checking)
        } else {
            self.configureUIForState(state: .NoAuth)
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
        
        self.hideOccupantSection()
        
    }
    
    func singleRefresh() {
        self.configureUIForState(state: .Checking)
        DatabaseHelpers.sharedInstance.singleRefresh(onDatabaseRefresh: {state in
            self.configureUIForState(state: state)
        })
    }
    
    func relinquishSpot() {
        DatabaseHelpers.sharedInstance.ref.child("spots").child("1").setValue([
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
        DatabaseHelpers.sharedInstance.ref.child("spots").child("1").setValue(mdata)
    }
    
    
    func openViewPressed() {
        
        if AccountHelpers.getCurrentUser() == nil {
            return
        }
        
        if AppState.sharedInstance.occupied {
            if (AppState.sharedInstance.occupied && AppState.sharedInstance.occupantUid == AppState.sharedInstance.uid) {
                let overlay = OverlayView.init(title: "Relinquish spot?", body: "If you leave the spot, its up for grabs.", confirmCallback: {
                    self.relinquishSpot()
                })
                self.view.addSubview(overlay)
            } else if(AppState.sharedInstance.occupied) {
                singleRefresh()
            } else {
                claimSpot()
            }
        } else {
            claimSpot()
        }
    }
    
    func hideOccupantSection() {
        self.occupiedViewVisible = false
        
        let distance = self.occupiedView.frame.size.height + 16 + self.tabBarController!.tabBar.frame.size.height
        self.occupiedView.layer.transform = CATransform3DMakeTranslation(0, distance, 0)
    }
    
    func animateOccupantSection(desiredState: AppState.SpotState, currentState: AppState.SpotState) {
        var direction = OccupiedSectionAnimationDirection.In
        let anim = POPSpringAnimation.init(propertyNamed: kPOPLayerTranslationY)
        let distance = self.occupiedView.frame.size.height + 16 + self.tabBarController!.tabBar.frame.size.height
        var key = String()
        
        let statesIn = [AppState.SpotState.Occupied, AppState.SpotState.Owned]
        let statesOut = [AppState.SpotState.Default, AppState.SpotState.NoAuth, AppState.SpotState.Open]
        
        if desiredState == .Checking {
            return
        }
        
        if self.occupiedViewVisible && statesOut.contains(desiredState) {
            direction = OccupiedSectionAnimationDirection.Out
        } else if !self.occupiedViewVisible && statesIn.contains(desiredState) {
            direction = OccupiedSectionAnimationDirection.In
        } else {
            return
        }
        
        switch direction {
        case .In:
            anim?.fromValue = distance
            anim?.toValue = 0
            key = "moveIn"
            self.occupiedViewVisible = true
        case .Out:
            anim?.fromValue = 0
            anim?.toValue = distance
            key = "moveOut"
            self.occupiedViewVisible = false
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

    
    func configureUIColors() {
        var color = AppState.sharedInstance.getColorForState()
        var ringColor = UIColor()
        var alertBgdColor = UIColor()
        let app = UIApplication.shared.delegate as! AppDelegate
        app.configureAppBgdColor()
        
        if color == nil {
            color = UIColor.white
        }

        ringColor = UIColor.blend(color1: color!, intensity1: 0.2, color2: UIColor.white, intensity2: 1)
        alertBgdColor = UIColor.blend(color1: color!, intensity1: 0.15, color2: Constants.Colors.darkGray, intensity2: 1)
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options:.curveEaseInOut, animations: {
            self.openViewBgd.backgroundColor = UIColor.clear
            self.openViewBgd.layer.borderColor = ringColor.cgColor
            self.openViewBgd.layer.borderWidth = 2
            self.occupiedView.backgroundColor = alertBgdColor
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

