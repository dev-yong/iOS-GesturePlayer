//
//  GSlider.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

import UIKit

@objc protocol GSliderDelegate {
    func valueChanged(_ sender: GSlider)
    func touchBegan(_ sender: GSlider)
    func touchEnd(_ sender: GSlider)
}
class GSlider: UISlider {
    var height: CGFloat = 2 {
        didSet {
            let height = self.height - 1
            self.bufferProgress.heightAnchor.constraint(equalToConstant: height).isActive = true
            self.bufferProgress.layer.cornerRadius = height / 2
        }
    }
    var delegate: GSliderDelegate?
    private lazy var bufferProgress: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.backgroundColor = .clear
        progress.isUserInteractionEnabled = false
        progress.progressTintColor = .white
        progress.trackTintColor = .gray
        progress.clipsToBounds = true
        return progress
    }()
    
    override var maximumTrackTintColor: UIColor? {
        didSet {
            self.bufferProgress.trackTintColor = self.maximumTrackTintColor
            super.maximumTrackTintColor = .clear
        }
    }
    
    var bufferTrackTintColor: UIColor? {
        didSet {
            self.bufferProgress.progressTintColor = bufferTrackTintColor
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = height
        return newBounds
    }
    
    init(delegate: GSliderDelegate) {
        self.init()
        self.delegate = delegate
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUp() {
        self.addSubview(self.bufferProgress)
        self.sendSubview(toBack: self.bufferProgress)
        self.addTarget(delegate, action: #selector(delegate?.valueChanged(_:)), for: UIControlEvents.valueChanged)
        self.addTarget(delegate, action: #selector(delegate?.touchBegan(_:)), for: .touchDown)
        self.addTarget(delegate, action: #selector(delegate?.touchEnd(_:)), for: [.touchUpInside, .touchUpOutside])
        self.bufferProgress.progress = 0.0
        self.bufferProgress.translatesAutoresizingMaskIntoConstraints = false
        self.bufferProgress.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.bufferProgress.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.bufferProgress.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
    }
    
    func setBufferProgress(value: Float) {
        self.bufferProgress.progress = value
    }
}
