//
//  ViewController.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import MediaPlayer

class GPlayerViewController: UIViewController {
    
    //MARK -: Property
    @IBOutlet weak var playerLayer: GPlayerLayer!
    @IBOutlet weak var playerControlView: GPlayerControlView!
    var layerManager: GPlayerLayerManager?
    var controlViewManager: GPlayerControlViewManager?
    var url: URL?
    var mpVolumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 100, height: 100))
    //MARK -: Method
    //MARK : LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layerManager = GPlayerLayerManager(playerLayer: playerLayer, delegate: self)
        controlViewManager = GPlayerControlViewManager(controlView: playerControlView, delegate: self)
        
        view.addSubview(mpVolumeView)
        mpVolumeView.showsRouteButton = false
        mpVolumeView.showsVolumeSlider = true
        for subview in mpVolumeView.subviews where subview is UISlider {
            controlViewManager?.volumeSlider =  subview as? UISlider
        }
        guard let url = self.url else {return}
        self.layerManager?.setPlayItem(url)
    }
    //MARK : Rotate ViewController
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.landscapeRight, UIInterfaceOrientationMask.landscapeLeft]
        return orientation
    }
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    //MARK : Set Player
    open func setPlayItem(urlStr: String) {
        self.url = URL(string: urlStr) 
    }
    
    open func setPlayItem(fileName: String, type: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            debugPrint("\(fileName).\(type) not found")
            return
        }
        self.url = URL(fileURLWithPath: path)
    }
}

extension GPlayerViewController: GPlayerLayerManagerDelegate {
    func player(playerLayerManger: GPlayerLayerManager, definition: Definition) {
        controlViewManager?.getDefinition(definition)
    }
    
    func player(playerLayerManger: GPlayerLayerManager, state: GPlayerState) {
        controlViewManager?.playerStateChanged(state: state)
    }
    
    func player(playerLayerManger: GPlayerLayerManager, playing: Bool) {
        controlViewManager?.player(isPlaying: playing)
    }
    
    func player(playerLayerManger: GPlayerLayerManager, loaded: TimeInterval, total: TimeInterval) {
        controlViewManager?.player(loaded: loaded, total: total)
    }
    
    func player(playerLayerManger: GPlayerLayerManager, current: TimeInterval, total: TimeInterval) {
        controlViewManager?.player(current: current, total: total)
    }
    
}

extension GPlayerViewController : GPlayerControlViewManagerDelegate {
    func player(controlViewManager: GPlayerControlViewManager, play sender: GButton) {
        layerManager?.player(play: !sender.isSelected)
    }
    
    func player(controlViewManager: GPlayerControlViewManager, replay sender: GButton) {
        layerManager?.replay()
    }
    func player(controlViewManager: GPlayerControlViewManager, back sender: GButton) {
        navigationController?.popViewController(animated: true)
        layerManager = nil
        dismiss(animated: true, completion: nil)
    }
    func player(controlViewManager: GPlayerControlViewManager, previous sender: GButton, time: TimeInterval) {
        layerManager?.seek(to: time)
    }
    
    func player(controlViewManager: GPlayerControlViewManager, isSeeking: Bool, time: TimeInterval?) {
        layerManager?.isSeeking(seeking: isSeeking)
        if let time = time {
            layerManager?.seek(to: time)
        }
    }
    func player(controlViewManager: GPlayerControlViewManager, doubleTapped sender: UITapGestureRecognizer) {
        layerManager?.changePlayerVideoGravity()
    }
    func player(controlViewManager: GPlayerControlViewManager, definition: Definition) {
        layerManager?.changeDefinition(definition)
    }
}
