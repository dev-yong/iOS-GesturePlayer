//
//  GPlayer.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 17..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import AVKit

protocol GPlayerLayerManagerDelegate {
    func player(playerLayerManger: GPlayerLayerManager ,state: GPlayerState)
    func player(playerLayerManger: GPlayerLayerManager, playing: Bool)
    func player(playerLayerManger: GPlayerLayerManager, loaded: TimeInterval, total: TimeInterval)
    func player(playerLayerManger: GPlayerLayerManager, current: TimeInterval, total: TimeInterval)
    func player(playerLayerManger: GPlayerLayerManager, definition: Definition)
}

class GPlayerLayerManager {
    //MARK: -Property
    var playerLayer: GPlayerLayer?
    var delegate: GPlayerLayerManagerDelegate?
    
    private var url: URL?
    private var asset: AVURLAsset?
    private var player: AVPlayer = AVPlayer()
    private var currentItem: AVPlayerItem? {
        return player.currentItem ?? nil
    }
    private var playBackTimeObserver: Any?
    private var playerItemObservers: [NSKeyValueObservation] = []
    private var videoGravity: AVLayerVideoGravity = .resizeAspect
    private var isSeeking = false
    private var isErrorOccurred: Bool = false
    private var definition: Definition = .auto
    //MARK: - Method
    //MARK : Initialize
    convenience init(playerLayer: GPlayerLayer, delegate: GPlayerLayerManagerDelegate) {
        self.init()
        self.playerLayer = playerLayer
        self.delegate = delegate
    }
    
    deinit {
        playerLayer?.player = nil
        removeObserver(player: player)
    }
    
    //MARK: Set Play Item
    func setPlayItem(_ url: URL, completion: (()->())? = nil) {
        removeObserver(player: player)
        isErrorOccurred = false
        self.url = url
        guard let url = self.url else {return}
        asset = AVURLAsset(url: url)
        guard let asset = self.asset else {return}
        asset.loadValuesAsynchronously(forKeys: [#keyPath(AVURLAsset.tracks)]) {
            DispatchQueue.main.async {
                self.delegate?.player(playerLayerManger: self, definition: self.definition)
                let playerItem = AVPlayerItem(asset: asset)
                playerItem.preferredPeakBitRate = self.definition.bitRate
                self.player.replaceCurrentItem(with: playerItem)
                self.playerLayer?.setPlayerLayer(player: self.player, videoGravity: self.videoGravity)
                guard let item = self.currentItem else {return}
                self.addObserver(player: self.player, playerItem: item)
                if let completion = completion {
                    completion()
                } else {
                    self.player(play: true)
                }
            }
        }
    }
    //MARK : KVO
    private func addObserver(player: AVPlayer, playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(playDidEnd(item:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerFailedToPlay(_:)),
                                               name: Notification.Name.AVPlayerItemFailedToPlayToEndTime,
                                               object: player.currentItem)

        let interval = CMTime(seconds:1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)) //nanosecond
        self.playBackTimeObserver = player.addPeriodicTimeObserver(forInterval: interval,
                                                                   queue: DispatchQueue.main) { [weak self] _ in
                                                                    guard let `self` = self else { return }
                                                                    if let error = player.error {
                                                                        print(error.localizedDescription)
                                                                        return
                                                                    }
                                                                    switch player.status {
                                                                    case .unknown:
                                                                        print("PeriodicTimeObserver - unkown")
                                                                    case .failed:
                                                                        self.errorOccurred()
                                                                    case .readyToPlay:
                                                                        if !self.isSeeking {
                                                                            self.delegate?.player(playerLayerManger: self,
                                                                                                  current: playerItem.currentTime().seconds,
                                                                                                  total: playerItem.duration.seconds)
                                                                        }
                                                                        if !self.isErrorOccurred {
                                                                            self.delegate?.player(playerLayerManger: self,
                                                                                                  playing: self.playerLayer?.isPlaying ?? false)
                                                                        }
                                                                    }
                                                                    switch player.timeControlStatus {
                                                                    case .paused, .waitingToPlayAtSpecifiedRate:
                                                                        break
                                                                    case .playing:
                                                                        if !self.isErrorOccurred {
                                                                            debugPrint("addPeriodicTimeObserver - bufferingEnd")
                                                                            self.delegate?.player(playerLayerManger: self,
                                                                                                  state: .bufferingEnd)
                                                                        }
                                                                    }
        }
        let playerItemStatusObserver = playerItem.observe(\.status) { [weak self](playerItem, changed) in
            guard let `self` = self else {return}
            guard let currentItem = self.currentItem else {return}
            switch currentItem.status {
            case .readyToPlay:
                self.delegate?.player(playerLayerManger: self, state: .ready)
                self.player(play: true)
            case .unknown:
                debugPrint("playerItemStatusObserver - Unknonw")
            case .failed:
                self.delegate?.player(playerLayerManger: self, state: .error)
            }
        }
        
        let playerItemLoadedTimeRanges = playerItem.observe(\.loadedTimeRanges) { [weak self](playerItem, changed) in
            guard let `self` = self else {return}
            self.delegate?.player(playerLayerManger: self, loaded: self.loading(item: playerItem),
                                  total: playerItem.duration.seconds)
        }
        let playerItemIsPlaybackBufferEmpty = playerItem.observe(\.isPlaybackBufferEmpty) { [weak self](playerItem, changed) in
            guard let `self` = self else {return}
            switch self.isErrorOccurred
            {
            case true:
                self.delegate?.player(playerLayerManger: self, state: .error)
            case false:
                debugPrint("isPlaybackBufferEmpty - buffering")
                self.delegate?.player(playerLayerManger: self, state: .buffering)
            }
        }
        let playerItemIsPlaybackLikelyToKeepUp = playerItem.observe(\.isPlaybackLikelyToKeepUp) { [weak self](playerItem, changed) in
            guard let `self` = self else {return}
            guard let currentItem = self.currentItem else {return}
            switch currentItem.isPlaybackLikelyToKeepUp {
            case true:
                debugPrint("isPlaybackLikelyToKeepUp - bufferingEnd")
                self.delegate?.player(playerLayerManger: self, state: .bufferingEnd)
            case false:
                if !self.isErrorOccurred {
                    debugPrint("isPlaybackLikelyToKeepUp - buffering")
                    self.delegate?.player(playerLayerManger: self, state: .buffering)
                }
            }
        }
        playerItemObservers.append(playerItemStatusObserver)
        playerItemObservers.append(playerItemLoadedTimeRanges)
        playerItemObservers.append(playerItemIsPlaybackBufferEmpty)
        playerItemObservers.append(playerItemIsPlaybackLikelyToKeepUp)
    }
    private func removeObserver(player: AVPlayer?) {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.AVPlayerItemFailedToPlayToEndTime,
                                                  object: nil)
        if let playBackTimeObserver = self.playBackTimeObserver {
            player?.removeTimeObserver(playBackTimeObserver)
            self.playBackTimeObserver = nil
        }
        for item in playerItemObservers {
            item.invalidate()
        }
    }
    
    @objc func playerFailedToPlay(_ notification: Notification) {
        if let userInfo = notification.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            NSLog("playerFailedToPlay Error: \(error.localizedDescription)")
        }
        errorOccurred()
    }
    
    @objc func playDidEnd(item playerItem: AVPlayerItem) {
        self.delegate?.player(playerLayerManger: self, state: .end)
    }
    func errorOccurred() {
        isErrorOccurred = true
    }
    //MARK : Control Player
    func player(play: Bool) {
        switch play {
        case true:
            self.playerLayer?.play()
        case false:
            self.playerLayer?.pause()
        }
    }
    
    func seek(to time: TimeInterval) {
        self.playerLayer?.seek(to: time)
    }
    
    func isSeeking(seeking: Bool) {
        self.isSeeking = seeking
    }
    private func loading(item: AVPlayerItem) -> TimeInterval{
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else {return 0.0}
        return timeRange.start.seconds + timeRange.duration.seconds
    }
    func changePlayerVideoGravity() {
        videoGravity = ( videoGravity == .resizeAspect ? .resizeAspectFill : .resizeAspect )
        playerLayer?.updatePlayerLayer(videoGravity: videoGravity)
    }
    func replay() {
        guard let url = self.url else {return}
        setPlayItem(url)
    }
    func changeDefinition(_ definition: Definition) {
        self.definition = definition
        var current: CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if let currentTime = currentItem?.currentTime() {
            current = currentTime
        }
        var playing = false
        playing = self.player.isPlaying
        
        guard let url = self.url else {return}
        setPlayItem(url) { [weak self] in
                        print(current.seconds)
                        self?.seek(to: current.seconds)
                        switch playing {
                        case true:
                            self?.player(play: true)
                        case false:
                            self?.player(play: true)
                        }
        }
    }
}
