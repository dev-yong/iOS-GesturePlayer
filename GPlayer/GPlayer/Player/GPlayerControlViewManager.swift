//
//  GPlayerControlViewManager.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 18..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import MediaPlayer

protocol GPlayerControlViewManagerDelegate {
    func player(controlViewManager: GPlayerControlViewManager, isSeeking: Bool, time: TimeInterval?)
    func player(controlViewManager: GPlayerControlViewManager, doubleTapped sender: UITapGestureRecognizer)
    func player(controlViewManager: GPlayerControlViewManager, play sender: GButton)
    func player(controlViewManager: GPlayerControlViewManager, replay sender: GButton)
    func player(controlViewManager: GPlayerControlViewManager, back sender: GButton)
    func player(controlViewManager: GPlayerControlViewManager, previous sender: GButton, time: TimeInterval)
    func player(controlViewManager: GPlayerControlViewManager, definition: Definition)
}

class GPlayerControlViewManager {
    //MARK: - Property
    var controlView: GPlayerControlView? 
    var delegate: GPlayerControlViewManagerDelegate?
    
    var duration = 0.0
    var currentTime = 0.0
    //Animation properties
    var isShowing: Bool = false
    var isLocked: Bool = false
    var isSliding: Bool = false
    var isPanning: Bool = false
    var endPlayback: Bool = false
    var seekStartTime: TimeInterval = 0.0
    var dispatchItem: DispatchWorkItem?
    var panGestureType: PanGestureType = .none
    var brightness: CGFloat = UIScreen.main.brightness
    var volume = AVAudioSession.sharedInstance().outputVolume
    var volumeSlider: UISlider?
    var definition: Definition = Default.definition
    //MARK: - Methods
    convenience init(controlView: GPlayerControlView, delegate: GPlayerControlViewManagerDelegate) {
        self.init()
        self.controlView = controlView
        self.controlView?.manager = self
        self.delegate = delegate
        volumeSlider?.value = volume
    }

    //Player Controler TouchUpAction
    func touchUpPlayAction(_ sender: GButton) {
        delegate?.player(controlViewManager: self, play: sender)
    }
    func touchUpLockAction(_ sender: GButton) {
        lockingAnimation(sender: sender, isTapped: isLocked)
        tapGestureAnimation(show: !isLocked)
        controlView?.lockPangestrue(locked: isLocked)
    }
    func touchUpRePlayAction(_ sender: GButton) {
        delegate?.player(controlViewManager: self, replay: sender)
    }
    func touchUpBackAction(_ sender: GButton) {
        delegate?.player(controlViewManager: self, back: sender)
    }
    func touchUpPreviousAction(_ sender: GButton) {
        let time = calculateSeekTime(startTime: currentTime, value: -10)
        delegate?.player(controlViewManager: self, previous: sender, time: time)
    }
    func getDefinition(_ definition: Definition) {
        self.definition = definition
        controlView?.udpateDefinitionButton(self.definition)
    }
    func changedDefinition(_ definition: Definition) {
        delegate?.player(controlViewManager: self, definition: definition)
    }
    func playerStateChanged(state: GPlayerState) {
        endPlayback = false
        switch state {
        case .ready:
            controlView?.replayAnimation(show: false)
            controlView?.updateIndicatorAnimation(show: false)
            dismissAnimation()
        case .buffering:
            controlView?.updateIndicatorAnimation(show: true)
        case .bufferingEnd:
            controlView?.updateIndicatorAnimation(show: false)
        case .end, .error:
            endPlayback = true
            controlView?.replayAnimation(show: true)
            tapGestureAnimation(show: true)
        }
    }
    func player(isPlaying : Bool) {
        controlView?.player(isPlaying: isPlaying)
    }
    func player(loaded: TimeInterval, total: TimeInterval) {
        duration = total
        controlView?.player(loaded: Float(loaded/total), total: Util.format(total))
    }
    func player(current: TimeInterval, total: TimeInterval) {
        self.currentTime = current
        controlView?.player(current: Util.format(current), sliderValue: Float(current / total))
    }
    private func calculateSeekTime(startTime: TimeInterval,value: TimeInterval) -> TimeInterval {
        var time = startTime + value
        time = time <= 0 ? 0 : time
        time = time >= duration ? duration : time
        return time
    }
    func player(slider sender: GSlider, event: UIControlEvents) {
        switch event {
        case .touchDown: // touchBegan
            isSliding = true
            delegate?.player(controlViewManager: self, isSeeking: isSliding, time: nil)
        case .valueChanged:
            player(current: TimeInterval(sender.value) * duration, total: duration)
        case [.touchUpInside, .touchUpOutside]: // touchEnd
            isSliding = false
            delegate?.player(controlViewManager: self, isSeeking: isSliding, time: TimeInterval(sender.value) * duration)
        default:
            break
        }
    }
    //Gestures
    func tapGestureChanged(_ tap: UITapGestureRecognizer) {
        if !endPlayback {
            tapGestureAnimation(show: !self.isShowing)
        }
    }
    func doubleTapGestureChanged(_ tap: UITapGestureRecognizer) {
        delegate?.player(controlViewManager: self, doubleTapped: tap)
    }
    func panGestureChanged(view: UIView, _ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: view)
        let velocity = pan.velocity(in: view)
        switch pan.state {
        case .began:
            if fabs(velocity.x) > fabs(velocity.y) {
                panGestureType = .seek
                seekStartTime = currentTime
                delegate?.player(controlViewManager: self, isSeeking: true, time: nil)
            }
            else if fabs(velocity.y) > fabs(velocity.x) {
                guard let controlView = self.controlView else {return}
                panGestureType = (location.x < controlView.frame.width / 2 ? .brightness : .volume)
            }
            panGestureAnimation(type: panGestureType, isPanning: true)
        case .changed:
            switch self.panGestureType {
            case .seek:
                seekStartTime = calculateSeekTime(startTime: seekStartTime, value: TimeInterval(velocity.x) / 1000)
                player(current: seekStartTime, total: duration)
            case .brightness:
                brightnessChanged(value: -(velocity.y / 40000))
            case .volume:
                volumeChanged(value: -(velocity.y / 40000))
            case .none:
                break
            }
        case .ended:
            if self.panGestureType == .seek{
                delegate?.player(controlViewManager: self, isSeeking: false, time: seekStartTime)
            }
            panGestureAnimation(type: panGestureType, isPanning: false)
        default:
            break
        }
    }
    private func lockingAnimation(sender: GButton, isTapped: Bool) {
        self.isLocked = !isTapped
        sender.isSelected = self.isLocked
        UIView.animate(withDuration: 0.5,
                       delay: 1.5,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.controlView?.lockButton.alpha = self.isLocked ? 0.0 : 1.0
        }, completion: nil)
    }
    //Animations
    private func tapGestureAnimation(show: Bool) {
        self.isShowing = show
        let alpha: CGFloat = self.isLocked ? 0.0 : (self.isShowing ? 1.0 : 0.0 )
        let alphaBackground: CGFloat = self.isLocked ? 0.0 : (self.isShowing ? 0.2 : 0.0)
        
        let options: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
        UIView.animate(withDuration:  0.5,
                       delay: 0,
                       options: options,
                       animations: {
                        self.controlView?.topContainerView.alpha = alpha
                        self.controlView?.bottomContainerView.alpha = alpha
                        self.controlView?.playButton.alpha = self.isPanning ? 0.0 : alpha
                        self.controlView?.lockButton.alpha = (self.isShowing ? 1.0 : 0.0 )
                        self.controlView?.backgroundColor = UIColor.black.withAlphaComponent(alphaBackground)
        }, completion: { _ in
            if self.isShowing {
                self.dismissAnimation()
            }
        })
    }
    private func dismissAnimation() {
        dispatchItem?.cancel()
        dispatchItem = DispatchWorkItem{
            if (!self.endPlayback && !self.isSliding && !self.isPanning) {
                self.tapGestureAnimation(show: false)
            }
        }
        guard let dispatchItem = self.dispatchItem else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 , execute: dispatchItem)
    }
    private func panGestureAnimation(type: PanGestureType, isPanning: Bool) {
        self.isPanning = isPanning
        let alpha: CGFloat = isPanning ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
                        self.controlView?.playButton.alpha = isPanning ? 0.0 : (self.isShowing ? 1.0 : 0.0)
                        self.controlView?.indicatorView.alpha = isPanning ? 0.0 : 1.0
                        self.controlView?.replayButton.alpha = isPanning ? 0.0 : 1.0
                        switch type {
                        case .seek:
                            self.controlView?.seekTimeLabel.alpha = alpha
                        case .brightness:
                            self.controlView?.brightnessVolumeLabel.alpha = alpha
                            self.controlView?.brightnessProgressView.alpha = alpha
                        case .volume:
                            self.controlView?.brightnessVolumeLabel.alpha = alpha
                            self.controlView?.volumeProgressView.alpha = alpha
                        case .none:
                            break
                        }
        }, completion: nil)
    }
    //Brightness Volume Calcuate
    private func brightnessChanged(value: CGFloat) {
        brightness += value
        brightness = brightness <= 0 ? 0 : brightness
        brightness = brightness >= 1 ? 1 : brightness
        UIScreen.main.brightness = brightness
        controlView?.updateBrightnessUI(brightness: brightness)
    }
    
    private func volumeChanged(value: CGFloat) {
        //Float : 32bit
        //Double: 64bit
        //CGFloate : 32 & 64 bit
        volume += Float(value)
        volume = volume <= 0 ? 0 : volume
        volume = volume >= 1 ? 1 : volume
        guard let volumeSlider = self.volumeSlider else {return}
        volumeSlider.value = volume
        controlView?.updateVolumeUI(volume: volumeSlider.value)
    }
}
