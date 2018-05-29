//
//  Enums.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
enum PanGestureType {
    case volume, brightness, seek, none
}

enum SeekType {
    case gesture, slider, none
}

//enum GPlayerControlViewButtonTag: Int {
//    case back = 0
//    case definition = 1
//    case subtitle = 2
//    case play = 3
//    case replay = 4
//    case previous = 5
//    case forward = 6
//    case lock = 7
//}

enum GPlayerState {
    case ready
    case buffering
    case bufferingEnd
    case end
    case error
}

enum Definition: Int, EnumCollection {
    case auto, definition224, definition360, definition540, definition720, definition1080
    var description: String {
        switch self {
        case .auto:
            return "AUTO"
        case .definition224:
            return "224p"
        case .definition360:
            return "360p"
        case .definition540:
            return "540p"
        case .definition720:
            return "720p"
        case .definition1080:
            return "1080p"
        }
    }
    
    var bitRate: Double {
        switch self {
        case .auto:
            return 0
        case .definition224:
            return 110000
        case .definition360:
            return 600000
        case .definition540:
            return 1800000
        case .definition720:
            return 4500000
        case .definition1080:
            return 11000000
        }
    }
}

enum Subtitle: Int, EnumCollection {
    case none, korean, english
    var description: String {
        switch self {
        case .none:
            return "CC"
        case .korean:
            return "한국어"
        case .english:
            return "영어"
        }
    }
}
