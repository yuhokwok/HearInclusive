//
//  ScanToSignLanguageViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import NaturalLanguage
import AVFoundation

class ScanToSignLanguageViewController: UIViewController {

    var playerLayer: AVPlayerLayer?
    var currentPlayer : AVPlayer?
    
    var text = ""
    var words : [String] = []
    var tokenizer = NLTokenizer(unit: .word)
    
    @IBOutlet var videoView : UIView!
    
    @IBOutlet var textField : UITextField!
    
    @IBAction func toSign(){
        text = textField.text!
        tokenizer.string = text
        words.removeAll()
        tokenizer.enumerateTokens(in: self.text.startIndex..<self.text.endIndex) {
            range, attributes in
            //print(string[range])
            let substring = text[range]
            self.words.append("\(substring)")
            return true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        
        
        // try catch to start audio session
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
    }
    
    
    @IBAction func play(){
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
