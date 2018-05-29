//
//  GButton.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class GButton: UIButton {
    convenience init(view: UIView,title: String? = nil, normalImage: UIImage? = nil, selector: Selector) {
        self.init(type: .custom)
        if let title = title {
            self.setTitle(title, for: .normal)
        }
        if let image = normalImage {
            self.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        self.addTarget(view, action: selector, for: .touchUpInside)
        self.tintColor = .white
    }
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.tintColor = Default.Color.lightGreen
            case false:
                self.tintColor = .white
            }
        }
    }
}
