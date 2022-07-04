//
//  InflightViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import AVFoundation
class InflightViewController: UIViewController {

    @IBOutlet var videoView : UIView!
    
    var playerLayer: AVPlayerLayer?
    var currentPlayer : AVPlayer?
    
    @IBOutlet var signLangView : UIView!
    var playerLayer2: AVPlayerLayer?
    var currentPlayer2 : AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        
        // try catch to start audio session
        do{
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
        
        self.currentPlayer?.pause()
        self.playerLayer?.removeFromSuperlayer()


        
        
        
        let videoURL: URL = Bundle.main.url(forResource: "ShortFilmV1", withExtension: "mp4")!
        let player = AVPlayer(url: videoURL)
        self.currentPlayer = player
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.frame = self.videoView!.bounds
        self.playerLayer?.videoGravity = .resizeAspect
        self.videoView.layer.addSublayer(self.playerLayer!)
        self.playerLayer?.player?.play()
        
        
        var items = [AVPlayerItem]()
        let part1: URL = Bundle.main.url(forResource: "part12", withExtension: "mov")!
        let part2: URL = Bundle.main.url(forResource: "part22", withExtension: "mov")!
        items.append(AVPlayerItem(url:part1))
        items.append(AVPlayerItem(url:part2))
        
        let player2 = AVQueuePlayer(items: items)
        self.currentPlayer2 = player2
        self.playerLayer2 = AVPlayerLayer(player: player2)
        self.playerLayer2!.frame = self.signLangView.bounds
        self.playerLayer2?.videoGravity = .resizeAspect
        self.signLangView.layer.addSublayer(self.playerLayer2!)
        self.playerLayer2?.player?.play()
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: {
//            notification in
//
//            player.seek(to: CMTime.zero)
//            player.play()
//
//        })
    }
    
    @IBAction func replay(){
        self.currentPlayer?.seek(to: CMTime.zero)
        self.currentPlayer2?.seek(to: CMTime.zero)
        
        self.currentPlayer?.play()
        self.currentPlayer2?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.currentPlayer?.pause()
        self.currentPlayer2?.pause()
        do{
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
