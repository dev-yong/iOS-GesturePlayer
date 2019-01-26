//
//  Video.swift
//  GPlayer
//
//  Created by 이광용 on 26/01/2019.
//  Copyright © 2019 이광용. All rights reserved.
//

import Foundation
import UIKit

enum VideoType {
    case local, remote
}

struct Videos {
    let type: VideoType
    let str: String
    let image: UIImage? = nil
}
