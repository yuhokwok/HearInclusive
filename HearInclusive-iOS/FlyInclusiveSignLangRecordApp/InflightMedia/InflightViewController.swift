//
//  InflightViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import AVFoundation
import Speech
import NaturalLanguage

class InflightViewController: UIViewController {

    @IBOutlet var videoView : UIView!
    
    @IBOutlet var subtitleLabel : UILabel!
    
    var videoMediaInput : VideoMediaInput?
    
    var playerLayer: AVPlayerLayer?
    var currentPlayer : AVPlayer?
    
    @IBOutlet var signLangView : UIView!
    var playerLayer2: AVPlayerLayer?
    var currentPlayer2 : AVPlayer?
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?

    var outputText = "";
    
    var words : [String] = []
    var tokenizer = NLTokenizer(unit: .word)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        
        // try catch to start audio session
        do{
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
        
        // try catch to start audio session
//        do{
//            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        }catch{
//            print("ERROR: - Audio Session Failed!")
//        }
//
        
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-hk"))
        //recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let inputURL: URL = Bundle.main.url(forResource: "lau", withExtension: "mp4")!
        videoMediaInput = VideoMediaInput(url: inputURL)
        videoMediaInput?.delegate = self
        videoMediaInput?.player.rate = 2.0
            
        self.playerLayer = AVPlayerLayer(player: videoMediaInput!.player)
        self.playerLayer!.frame = self.videoView!.bounds
        self.playerLayer?.videoGravity = .resizeAspect
        self.videoView.layer.addSublayer(self.playerLayer!)
        
        //self.playerLayer?.player?.play()
        
        
        //self.currentPlayer?.pause()
        //self.playerLayer?.removeFromSuperlayer()

        
//        let videoURL: URL = Bundle.main.url(forResource: "ShortFilmV1", withExtension: "mp4")!
//        let player = AVPlayer(url: videoURL)
//        self.currentPlayer = player
//        self.playerLayer = AVPlayerLayer(player: player)
//        self.playerLayer!.frame = self.videoView!.bounds
//        self.playerLayer?.videoGravity = .resizeAspect
//        self.videoView.layer.addSublayer(self.playerLayer!)
//        self.playerLayer?.player?.play()
        
        
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
        

        print("start recording")
        // restarts the text


        // Create and configure the speech recognition request.
        self.request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = false
        
        
        if #available(iOS 16, *) {
            print("add puncutation")
            recognitionRequest.addsPunctuation = true
        } else {
            // Fallback on earlier versions
        }
        
        
        recognitionRequest.taskHint = SFSpeechRecognitionTaskHint.dictation
        recognitionRequest.requiresOnDeviceRecognition = true
        // Create a recognition task for the speech recognition session.
        task = recognizer?.recognitionTask(with: recognitionRequest){ result, error in
            if (result != nil){
                self.outputText = (result?.bestTranscription.formattedString)!
            }
            if let result = result{
                // Update the text view with the results.
                if result.isFinal {
                    print("clear triggered word")
                }
                
                
                
                self.outputText = result.bestTranscription.formattedString ?? ""
                
                //self.delegate?.speech(self, result: "\(self.outputText)")
                
//                if let transcription = result.bestTranscription {
//
//                    for segment in transcription.segments {
//                        print("duration: \(segment.duration)")
//                        print("timestamp: \(segment.timestamp)")
//                        print("substring: \(segment.substring)")
//                    }
//                }
                
                print("detect: \(self.outputText)")
                
                DispatchQueue.main.async {
                    self.subtitleLabel.text = self.outputText
                    
                    self.tokenizer.string = self.outputText
                    self.words.removeAll()
                    
                    self.tokenizer.enumerateTokens(in: self.outputText.startIndex..<self.outputText.endIndex) {
                        range, attributes in
                        let substring = self.outputText[range]
                        self.words.append("\(substring)")
                        return true
                    }
                    print("detect: \(self.outputText)")
                    print("\(self.words)")
                }
            }
            if error != nil {
                self.request = nil
                self.task = nil
                
            }
        }
        
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


extension InflightViewController : VideoMediaInputDelegate {
    func videoFrameRefresh(sampleBuffer: CMSampleBuffer) {
        //print("refresh")
        //print("append buffer")
        self.request?.appendAudioSampleBuffer(sampleBuffer)
//        self.recognitionRequest?.append(buffer)
    }
}
