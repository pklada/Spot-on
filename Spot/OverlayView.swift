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
    
    @IBOutlet var view: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var primaryButton: Button!
    @IBOutlet var secondaryButton: Button!
    
    let width = 315
    let margin = 16
    var title = String()
    var body = String()
    
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
        Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)
        self.backgroundColor = UIColor.clear
        self.addSubview(self.view)
        let x = (Int(UIScreen.main.bounds.width) - self.width) / 2
        
        let font = UIFont(name: Constants.Fonts.normal, size: 18.0)
        let bodyHeight = heightForView(text: self.body, font: font!, width: CGFloat(self.width - 32))
        let height = 105 + CGFloat(margin * 3) + bodyHeight
        
        self.view.frame = CGRect(x: x, y: 230, width: self.width, height: Int(height))
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
        
        self.view.layer.cornerRadius = CGFloat(Constants.Dimens.cornerRadius)
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.view.layer.shadowRadius = 12
        self.view.layer.shadowOpacity = 0.25
        self.view.clipsToBounds = false
        
        self.displayShim()
        self.displayOverlay()
    }
    
    func displayOverlay() {
        let toValue = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        let fromValue = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 50, width: self.view.frame.size.width, height: self.view.frame.size.height)
        AnimationHelper.createSpringAnimation(property: kPOPViewFrame, toValue: toValue, fromValue: fromValue, target: self.view, keyName: "displayOverlay")
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hideOverlay() {
        let toValue = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 50, width: self.view.frame.size.width, height: self.view.frame.size.height)
        let fromValue = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
        AnimationHelper.createSpringAnimation(property: kPOPViewFrame, toValue: toValue, fromValue: fromValue, target: self.view, springSpeed: 6, keyName: "hideOverlay")
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bodyLabel.preferredMaxLayoutWidth = self.bodyLabel.frame.size.width;
        self.view.layoutIfNeeded()
        super.layoutSubviews()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        self.bodyLabel.preferredMaxLayoutWidth = self.bodyLabel.frame.size.width;
        self.view.layoutIfNeeded()
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
