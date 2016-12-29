//
//  AvatarView.swift
//  Spot
//
//  Created by Peter on 12/26/16.
//  Copyright © 2016 Peter. All rights reserved.
//

import UIKit
import Foundation

class AvatarView: UIView {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.layer.cornerRadius = self.frame.size.height / 2
        self.view.clipsToBounds = true
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clear
    }
    
    func initialize() {
        Bundle.main.loadNibNamed("AvatarView", owner: self, options: nil)
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    func setShadow(size: CGSize = CGSize(width: 0, height: 4), opacity: Float = 0.25, radius: CGFloat = 24) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func setImage(url: String) {
        self.avatarImage.downloadedFrom(link: "\(url)")
    }
}
