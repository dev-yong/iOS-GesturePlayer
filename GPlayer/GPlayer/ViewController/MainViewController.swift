//
//  MainViewController.swift
//  GPlayer
//
//  Created by 이광용 on 2018. 5. 18..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    var videos: [Videos] = [Videos(type: .local, str: "rain"), Videos(type: .local, str: "water")]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        fetchRequestList()
    }
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return false
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    func fetchRequestList() {
        //"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        //"http://devstreaming.apple.com/videos/wwdc/2016/503lkp4vimgv7tqecn7/503/hls_vod_mvp.m3u8"
        //"http://www.html5videoplayer.net/videos/toystory.mp4"
        //"https://devstreaming-cdn.apple.com/videos/wwdc/2017/514tjrrgnguh4k/514/hls_vod_mvp.m3u8"
        self.videos.append(Videos(type: .remote, str: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"))
        self.videos.append(Videos(type: .remote, str: "http://devstreaming.apple.com/videos/wwdc/2016/503lkp4vimgv7tqecn7/503/hls_vod_mvp.m3u8"))
        self.videos.append(Videos(type: .remote, str: "http://www.html5videoplayer.net/videos/toystory.mp4"))
        self.videos.append(Videos(type: .remote, str: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/514tjrrgnguh4k/514/hls_vod_mvp.m3u8"))
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as! TableViewCell
        cell.info = videos[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width * 9/16 + 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playerViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: GPlayerViewController.reuseIdentifier) as! GPlayerViewController
        let video = videos[indexPath.row]
        switch video.type {
        case .local:
            playerViewController.setPlayItem(fileName: video.str, type: "mp4")
        case .remote:
            playerViewController.setPlayItem(urlStr: video.str)
        }
        self.present(playerViewController, animated: true, completion: nil)
    }
}
