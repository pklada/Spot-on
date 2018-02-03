//
//  AvatarView.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import Foundation
import pop

class OverlayView: UIView {
    
    var confirmCallback: ((Void) -> Void)?
    
    // loaded from NIB
    private weak var view: UIView!
    
    @IBOutlet var overlayView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var primaryButton: Button!
    @IBOutlet var secondaryButton: Button!
    
    let width = 315
    let margin = 16
    var title = String()
    var body = String()
    var shouldUpdateConstraints: Bool = true
    var overlayNeedsDisplay: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    convenience init(title: String = "Alert", body: String = "", confirmCallback: ((Void) -> Void)? = nil)  {
        self.init(frame: UIScreen.main.bounds)
        self.title = title
        self.body = body
        if confirmCallback != nil {
            self.confirmCallback = confirmCallback
        }
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initialize() {
        self.view = Bundle (for: type(of: self)).loadNibNamed(
            "OverlayView", owner: self, options: nil)! [0] as! UIView
        self.backgroundColor = UIColor.clear
        self.configureUI()
    }
    
    func configureUI() {
        self.alpha = 0
        self.titleLabel.text = self.title
        self.bodyLabel.text = self.body
        self.bodyLabel.font = UIFont(name: Constants.Fonts.normal, size: 18.0)
        self.bodyLabel.numberOfLines = 0
        self.bodyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        self.titleLabel.textColor = Constants.Colors.darkGray
        self.bodyLabel.textColor = Constants.Colors.darkGray
        
        self.primaryButton.setupForPrimary()
        self.secondaryButton.setupForSecondary()
        
        self.overlayView.layer.cornerRadius = CGFloat(Constants.Dimens.cornerRadius)
        self.overlayView.layer.shadowColor = UIColor.black.cgColor
        self.overlayView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.overlayView.layer.shadowRadius = 12
        self.overlayView.layer.shadowOpacity = 0.25
        self.overlayView.clipsToBounds = false
        
        self.overlayView.invalidateIntrinsicContentSize()
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.overlayView)
    }
    
    func displayOverlay() {
        let toValue = CGRect(x: self.overlayView.frame.origin.x, y: self.overlayView.frame.origin.y, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height)
        let fromValue = CGRect(x: self.overlayView.frame.origin.x, y: self.overlayView.frame.origin.y + 50, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height)
        AnimationHelper.createSpringAnimation(property: kPOPViewFrame, toValue: toValue, fromValue: fromValue, target: self.overlayView, keyName: "displayOverlay")
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hideOverlay() {
        let toValue = CGRect(x: self.overlayView.frame.origin.x, y: self.overlayView.frame.origin.y + 50, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height)
        let fromValue = CGRect(x: self.overlayView.frame.origin.x, y: self.overlayView.frame.origin.y, width: self.overlayView.frame.size.width, height: self.overlayView.frame.size.height)
        AnimationHelper.createSpringAnimation(property: kPOPViewFrame, toValue: toValue, fromValue: fromValue, target: self.overlayView, springSpeed: 6, keyName: "hideOverlay")
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        })
    }
    
    func displayShim() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        })
    }
    
    func removeShim() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = UIColor.clear
        })
    }
    
    func closeOverlay() {
        self.hideOverlay()
        self.removeShim()
        
        let deadlineTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.removeFromSuperview()
        }

    }
    
    override func updateConstraints() {
        if (shouldUpdateConstraints) {
            NSLayoutConstraint(item: self.overlayView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.overlayView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.overlayView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(self.width)).isActive = true
            shouldUpdateConstraints = false
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.overlayView.layoutIfNeeded()
        
        if (overlayNeedsDisplay) {
            self.displayOverlay()
            self.displayShim()
            overlayNeedsDisplay = false
        }
        super.layoutSubviews()
    }
    
    @IBAction func confirmButtonTapped() {
        self.closeOverlay()
        self.confirmCallback!()
    }
    
    @IBAction func cancelButtonTapped() {
        self.closeOverlay()
    }
}
