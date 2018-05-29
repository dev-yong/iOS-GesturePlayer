//
//  GPlayerControlView.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit


class GPlayerControlView: UIView {
    //MARK: - Property
    private var topBottomContainerViewHeight: CGFloat = 60.0
    var manager: GPlayerControlViewManager?
    //MARK : Gestures
    lazy var tapGestrue = UITapGestureRecognizer(target: self, action: #selector(tapGestureChanged(_:)))
    lazy var doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureChanged(_:)))
    lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureChanged(_:)))
    //MARK : View Components
    //Container View
    let topContainerView: UIView = UIView()
    let bottomContainerView: UIView = UIView()
    let gestureAllowView: UIView = UIView()
    //Center Components
    lazy var playButton: GButton = {
        let button = GButton(view: self,
                             normalImage: #imageLiteral(resourceName: "playerPlayDefault"),
                             selector: #selector(touchUpPlayAction(_:)))
        button.setImage(#imageLiteral(resourceName: "playerPauseDefault"), for: .selected)
        return button
    }()
    var seekTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: FontSize.seekTime)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    lazy var lockButton: UIButton = {
        let btn = GButton(view: self, normalImage: #imageLiteral(resourceName: "UnLock"), selector: #selector(touchUpLockAction(_:)))
        btn.setImage(#imageLiteral(resourceName: "Lock").withRenderingMode(.alwaysTemplate), for: .selected)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.imageEdgeInsets.top = 10
        btn.imageEdgeInsets.bottom = 10
        btn.imageEdgeInsets.left = 10
        btn.imageEdgeInsets.right = 10
        btn.layer.cornerRadius = 5
        return btn
    }()
    var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        indicator.layer.cornerRadius = 5
        return indicator
    }()
    lazy var replayButton: UIButton = {
        let btn = GButton(view: self, normalImage: #imageLiteral(resourceName: "Replay"), selector: #selector(touchUpRePlayAction(_:)))
        return btn
    }()
    //Brightness Volume Progress Compontents
    var brightnessProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = Default.Color.green.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    var brightnessProgressViewHeightConstraint: NSLayoutConstraint?
    var volumeProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = Default.Color.green.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    var volumeProgressViewHeightConstraint: NSLayoutConstraint?
    var maskProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    var brightnessVolumeProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = Default.Color.lightGreen
        return view
    }()
    var brightnessVolumeProgressViewHeightConstraint: NSLayoutConstraint?
    var brightnessVolumeLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: FontSize.seekTime)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    //Top ContainerView Components
    lazy var backButton: UIButton = GButton(view: self,
                                            normalImage: #imageLiteral(resourceName: "navigationBack"),
                                            selector: #selector(touchUpBackAction(_:)))
    lazy var definitionButton: UIButton = {
        let btn = GButton(view: self, title: Definition.auto.description, selector: #selector(touchUpDefinitionAction(_:)))
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: FontSize.button)
        return btn
    }()
    //Bottom ContainerView Components
    lazy var perviousButton: GButton = {
        let button = GButton(view: self,
                             normalImage: #imageLiteral(resourceName: "playerBtnBefore10SDefualt"),
                             selector: #selector(touchUpPreviousAction(_:)))
        return button
    }()
     lazy var timeSlider: GSlider = {
        let slider = GSlider(delegate: self)
        slider.height = 5
        slider.minimumTrackTintColor = Default.Color.green
        slider.maximumTrackTintColor = .gray
        slider.bufferTrackTintColor = .white
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        
        return slider
    }()
     var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: FontSize.time)
        label.text = "00:00"
        label.textColor = Default.Color.green
        return label
    }()
     var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: FontSize.time)
        label.text = "--:--"
        label.textColor = .white
        return label
    }()
    //Slide Up Menu
    let slideUpMenu: GSlideUpMenu = GSlideUpMenu()
    
    //MARK: - Method
    //MARK: Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    //MARK: Set Up UI
    private func setUp() {
        setUpUI()
        setUpConstraint()
        setUpGestures()
    }
    
    override func layoutSubviews() {
        brightnessVolumeLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        brightnessVolumeLabel.center = maskProgressView.center
        super.layoutSubviews()
    }

    private func setUpUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        clipsToBounds = true

        replayButton.isHidden = true
        
        //Brightness ContainerView Components
        addSubview(brightnessProgressView)
        addSubview(volumeProgressView)
        addSubview(maskProgressView)
        maskProgressView.addSubview(brightnessVolumeProgressView)
        maskProgressView.mask = brightnessVolumeLabel
        
        //ContainerViews
        addSubview(topContainerView)
        addSubview(bottomContainerView)
        addSubview(gestureAllowView)
        
        //Center Components
        addSubview(playButton)
        addSubview(seekTimeLabel)
        addSubview(lockButton)
        addSubview(indicatorView)
        addSubview(replayButton)
        
        //Top ContainerView Components
        topContainerView.addSubview(backButton)
        topContainerView.addSubview(definitionButton)
        
        //Bottom ContainerView Components
        bottomContainerView.addSubview(perviousButton)
        bottomContainerView.addSubview(timeSlider)
        bottomContainerView.addSubview(currentTimeLabel)
        bottomContainerView.addSubview(totalTimeLabel)
    }
    
    private func setUpGestures() {
        tapGestrue.numberOfTapsRequired = 1
        gestureAllowView.addGestureRecognizer(tapGestrue)
        doubleTapGesture.numberOfTapsRequired = 2
        gestureAllowView.addGestureRecognizer(doubleTapGesture)
        tapGestrue.require(toFail: doubleTapGesture)
        gestureAllowView.addGestureRecognizer(panGesture)
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1

    }
    
    private func setUpConstraint() {
        //ContainerViews
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        topContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        topContainerView.heightAnchor.constraint(equalToConstant: topBottomContainerViewHeight).isActive = true
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        bottomContainerView.heightAnchor.constraint(equalToConstant: topBottomContainerViewHeight).isActive = true
        
        gestureAllowView.translatesAutoresizingMaskIntoConstraints = false
        gestureAllowView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true
        gestureAllowView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true
        gestureAllowView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        gestureAllowView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        //Brightness ContainerView Components
        brightnessProgressView.translatesAutoresizingMaskIntoConstraints = false
        brightnessProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        brightnessProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        brightnessProgressView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        volumeProgressView.translatesAutoresizingMaskIntoConstraints = false
        volumeProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        volumeProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        volumeProgressView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        maskProgressView.translatesAutoresizingMaskIntoConstraints = false
        maskProgressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        maskProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        maskProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        maskProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        brightnessVolumeProgressView.translatesAutoresizingMaskIntoConstraints = false
        brightnessVolumeProgressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        brightnessVolumeProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        brightnessVolumeProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        //Center Components
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: gestureAllowView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: gestureAllowView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: IconSize.center).isActive = true
        playButton.addConstraint(NSLayoutConstraint(item: playButton,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: playButton,
                                                         attribute: .width,
                                                         multiplier: 1.0,
                                                         constant: 0))
        
        seekTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        seekTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        seekTimeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        lockButton.translatesAutoresizingMaskIntoConstraints = false
        lockButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lockButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        lockButton.heightAnchor.constraint(equalToConstant: IconSize.center + 15).isActive = true
        lockButton.addConstraint(NSLayoutConstraint(item: lockButton,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: lockButton,
                                                    attribute: .height,
                                                    multiplier: 1,
                                                    constant: 0))
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        replayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        replayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        replayButton.widthAnchor.constraint(equalToConstant: IconSize.center).isActive = true
        replayButton.addConstraint(NSLayoutConstraint(item: replayButton,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: replayButton,
                                                      attribute: .height,
                                                      multiplier: 1,
                                                      constant: 0))
        //Top ContainerView Components
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: IconSize.topBottom).isActive = true
        backButton.addConstraint(NSLayoutConstraint(item: backButton,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: backButton,
                                                    attribute: .height,
                                                    multiplier: 1,
                                                    constant: 0))
        
        definitionButton.translatesAutoresizingMaskIntoConstraints = false
        definitionButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor).isActive = true
        definitionButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        definitionButton.heightAnchor.constraint(equalToConstant: IconSize.topBottom).isActive = true
        definitionButton.addConstraint(NSLayoutConstraint(item: definitionButton,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: definitionButton,
                                                          attribute: .height,
                                                          multiplier: 2,
                                                          constant: 0))
        //Bottom ContainerView Components
        perviousButton.translatesAutoresizingMaskIntoConstraints = false
        perviousButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor).isActive = true
        perviousButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor).isActive = true
        perviousButton.widthAnchor.constraint(equalToConstant: IconSize.topBottom).isActive = true
        perviousButton.addConstraint(NSLayoutConstraint(item: perviousButton,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: perviousButton,
                                                            attribute: .width,
                                                            multiplier: 1.0,
                                                            constant: 0))
        
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor).isActive = true
        timeSlider.leadingAnchor.constraint(equalTo: perviousButton.trailingAnchor, constant: 20).isActive = true
        timeSlider.trailingAnchor.constraint(equalTo: currentTimeLabel.leadingAnchor, constant: -20).isActive = true
        
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        totalTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        totalTimeLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -10).isActive = true
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalTo: totalTimeLabel.widthAnchor).isActive = true
        bottomContainerView.addConstraint(NSLayoutConstraint(item: currentTimeLabel,
                                                                  attribute: .trailing,
                                                                  relatedBy: .equal,
                                                                  toItem: totalTimeLabel,
                                                                  attribute: .leading,
                                                                  multiplier: 1,
                                                                  constant: -10))
    }
    
    //MARK : Did Changed
    func player(isPlaying : Bool) {
        playButton.isSelected = isPlaying
    }
    func player(loaded: Float, total: String) {
        timeSlider.setBufferProgress(value: loaded)
        totalTimeLabel.text = total
    }
    func player(current: String, sliderValue: Float ) {
        currentTimeLabel.text = current
        seekTimeLabel.text = current
        timeSlider.setValue(sliderValue, animated: true)
    }
    @objc func touchUpPlayAction(_ sender: GButton) {
        manager?.touchUpPlayAction(sender)
    }
    @objc func touchUpLockAction(_ sender: GButton) {
        manager?.touchUpLockAction(sender)
    }
    @objc func touchUpRePlayAction(_ sender: GButton) {
        manager?.touchUpRePlayAction(sender)
    }
    @objc func touchUpBackAction(_ sender: GButton) {
        manager?.touchUpBackAction(sender)
    }
    @objc func touchUpPreviousAction(_ sender: GButton) {
        manager?.touchUpPreviousAction(sender)
    }
    func udpateDefinitionButton(_ definition: Definition) {
        definitionButton.setTitle(definition.description, for: .normal)
    }
    @objc func touchUpDefinitionAction(_ sender: GButton) {
        guard let definition = manager?.definition else {return}
        presentSlideUpMenu(data: Definition.allCases, selected: definition.rawValue)
    }
    @objc func tapGestureChanged(_ tap: UITapGestureRecognizer) {
        manager?.tapGestureChanged(tap)
    }
    @objc func doubleTapGestureChanged(_ tap: UITapGestureRecognizer) {
        manager?.doubleTapGestureChanged(tap)
    }
    @objc func panGestureChanged(_ pan: UIPanGestureRecognizer) {
        manager?.panGestureChanged(view: self, pan)
    }
    func updateIndicatorAnimation(show: Bool) {
        playButton.isHidden = show
        indicatorView.isHidden = !show
        replayButton.isHidden = true
        switch show {
        case true:
            self.indicatorView.startAnimating()
        case false:
            self.indicatorView.stopAnimating()
        }
    }
    func replayAnimation(show: Bool) {
        playButton.isHidden = show
        indicatorView.isHidden = true
        replayButton.isHidden = !show
    }
    func lockPangestrue(locked: Bool) {
        switch locked {
        case true:
            gestureAllowView.removeGestureRecognizer(panGesture)
        case false:
            gestureAllowView.addGestureRecognizer(panGesture)
        }
    }
    func updateBrightnessUI(brightness: CGFloat) {
        brightnessVolumeLabel.text = "\(Int(brightness * 100))"
        brightnessProgressViewHeightConstraint?.isActive = false
        brightnessProgressViewHeightConstraint = brightnessProgressView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: brightness)
        brightnessProgressViewHeightConstraint?.isActive = true
        brightnessVolumeProgressViewHeightConstraint?.isActive = false
        brightnessVolumeProgressViewHeightConstraint = brightnessVolumeProgressView.heightAnchor.constraint(equalTo: self.heightAnchor,
                                                                                                            multiplier: brightness)
        brightnessVolumeProgressViewHeightConstraint?.isActive = true
    }
    
    func updateVolumeUI(volume: Float) {
        brightnessVolumeLabel.text = "\(Int(volume * 100))"
        volumeProgressViewHeightConstraint?.isActive = false
        volumeProgressViewHeightConstraint = volumeProgressView.heightAnchor.constraint(equalTo: self.heightAnchor,
                                                                                        multiplier: CGFloat(volume))
        volumeProgressViewHeightConstraint?.isActive = true
        brightnessVolumeProgressViewHeightConstraint?.isActive = false
        brightnessVolumeProgressViewHeightConstraint = brightnessVolumeProgressView.heightAnchor.constraint(equalTo: self.heightAnchor,
                                                                                                            multiplier: CGFloat(volume))
        brightnessVolumeProgressViewHeightConstraint?.isActive = true
    }
    func presentSlideUpMenu(data: [Any], selected: Int) {
        self.addSubview(slideUpMenu)
        slideUpMenu.delegate = self
        slideUpMenu.translatesAutoresizingMaskIntoConstraints = false
        slideUpMenu.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        slideUpMenu.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        slideUpMenu.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        slideUpMenu.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        slideUpMenu.data = data
        slideUpMenu.selectedIndex = selected
        slideUpMenu.slideUpMenuAnimation(show: true)
    }
}

extension GPlayerControlView: GSliderDelegate {
    func valueChanged(_ sender: GSlider) {
        manager?.player(slider: sender, event: .valueChanged) 
    }
    
    func touchBegan(_ sender: GSlider) {
        manager?.player(slider: sender, event: .touchDown)
    }
    
    func touchEnd(_ sender: GSlider) {
        manager?.player(slider: sender, event: [.touchUpInside, .touchUpOutside])
    }
}

extension GPlayerControlView: GSlideUpMenuDelgate {
    func gSlideUpMenu<T>(menu: GSlideUpMenu, data: T) where T : EnumCollection {
        if let selected = data as? Definition {
            manager?.changedDefinition(selected)
        }
    }
}
