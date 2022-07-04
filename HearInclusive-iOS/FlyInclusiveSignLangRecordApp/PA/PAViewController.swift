//
//  PAViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import AVFoundation

class PAViewController : UIViewController {
    
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var videoView : UIImageView!
    
    
    var playerLayer: AVPlayerLayer?
    var currentPlayer : AVPlayer?
    
    
    var text = ""
    var words : [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.messageLabel.text = text
        
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

        var items = [AVPlayerItem]()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        for word in words {
            var documentsDirectory = paths[0]
            documentsDirectory.appendPathComponent("signs/\(word.lowercased()).mp4")
            print("path: \(documentsDirectory.path)")
            if FileManager.default.fileExists(atPath: documentsDirectory.path){
                //let asset = AVAsset(url: documentsDirectory)
                print("added item")
                let item = AVPlayerItem(url: documentsDirectory)
                items.append(item)
            }
        }
        
        
        
        //let videoURL: URL = documentsDirectory
        //Bundle.main.url(forResource: "sign", withExtension: "mp4")!
        let player = AVQueuePlayer(items: items)
        //AVPlayer(url: videoURL)
        self.currentPlayer = player
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.frame = self.videoView!.bounds
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.videoView.layer.addSublayer(self.playerLayer!)
        self.playerLayer?.player?.play()
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: {
            notification in
            
            player.seek(to: CMTime.zero)
            player.play()
            
        })
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
        
        super.viewWillDisappear(animated)
    }
}
