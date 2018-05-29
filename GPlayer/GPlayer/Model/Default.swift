//
//  Default.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

//95 222 138/95 222 161/85 186 212
struct Default {
    static var subtitle: Subtitle = .none
    static var definition: Definition = .auto
    struct Color {
        static var green: UIColor = UIColor(red: 78/255, green: 184/255, blue: 73/255, alpha: 1)
        static var lightGreen: UIColor = UIColor(red: 117/255, green: 255/255, blue: 128/255, alpha: 1)
    }
}
struct FontSize {
    static var time: CGFloat = 12
    static var button: CGFloat = 15
    static var seekTime: CGFloat = 50
}
struct IconSize {
    static var topBottom: CGFloat = 25
    static var center: CGFloat = 40
}

