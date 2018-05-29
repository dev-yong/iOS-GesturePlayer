//
//  GPlayerView.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import AVKit

class GPlayerLayer: UIView {
    //MARK: - Property
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    var currentItem: AVPlayerItem? {
        return self.player?.currentItem
    }
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    var isPlaying: Bool {
        return self.player?.isPlaying ?? false
    }
    var currentTime: TimeInterval {
        return self.currentItem?.currentTime().seconds ?? 0.0
    }
    //MARK: - Methods
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    //MARK: Set Up
    func setPlayerLayer(player: AVPlayer?, videoGravity: AVLayerVideoGravity) {
        self.playerLayer.player = player
        updatePlayerLayer(videoGravity: videoGravity)
    }
    //MARK: Control Player
    func play(){
        self.player?.play()
    }
    func pause() {
        self.player?.pause()
    }
    func seek(to time: TimeInterval ) {
        self.player?.seek(to: CMTimeMake(Int64(time), 1))
    }
    func updatePlayerLayer(videoGravity: AVLayerVideoGravity) {
        playerLayer.videoGravity = videoGravity
    }

}
