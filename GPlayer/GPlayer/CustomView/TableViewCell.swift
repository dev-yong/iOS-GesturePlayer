//
//  TableViewCell.swift
//  GPlayer
//
//  Created by 이광용 on 26/01/2019.
//  Copyright © 2019 이광용. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    var info: Videos? {
        didSet {
            if let image = info?.image {
                thumbnail.image = image
            }
            title.text = info?.str
        }
    }
}
