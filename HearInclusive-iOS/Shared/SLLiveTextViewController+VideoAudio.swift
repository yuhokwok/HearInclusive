//
//  SLLiveTextViewController+VideoAudio.swift
//  Photo
//
//  Created by Yu Ho Kwok on 1/9/2022.
//

import NaturalLanguage
import MobileCoreServices
import Speech
import DSWaveformImage
import UIKit


extension SLLiveTextViewController {
    
    
    func processForAudio(url : URL) {
        
        DispatchQueue.main.async {
            let waveformImageView = WaveformImageView(frame: self.waveformImageContainer.bounds)
            let configuration = Waveform.Configuration(style: .striped(.init(color: #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), width: 4)), position: .middle, paddingFactor: 5)
            waveformImageView.configuration = configuration
            waveformImageView.waveformAudioURL = url
            self.waveformImageContainer.addSubview(waveformImageView)
        }
        
        AudioSpeechAnalyser.shared.delegate = self
        AudioSpeechAnalyser.shared.transcribeFile(url: url)
        
        playerVideo.url = url
    }
    
    func processForVideo(url : URL){
        self.extractAudio(url: url)
        
        playerVideo.delegate = self
        playerVideo.fillMode = .resizeAspectFill
        playerVideo.url = url
        //playerVideo.play()
        
    }
    
}


extension SLLiveTextViewController : AudioSpeechAnalyserDelegate {
    func audioSpeechAnalyser(_ analyser: AudioSpeechAnalyser, didOutput text: String, isFinal: Bool) {
        DispatchQueue.main.async {
            if self.mediaRecognitionMode == 0 {
                self.handleAudio(text: text, isFinal: isFinal)
            } else {
                self.handleVideo(text: text, isFinal: isFinal)
            }
        }
    }
    
    func handleVideo(text : String, isFinal: Bool) {
        //print("\(text)")
        if isFinal {
            self.sentences = NLPEngine.shared.process(text)
            self.collectionView?.reloadData()
            
                        
            self.fetchSignForSentences()

        }
    }
    
    func handleAudio(text : String, isFinal: Bool) {
        self.label?.text = "\(text)"
        
        
        if isFinal {
            self.sentences = NLPEngine.shared.process(text)
            self.collectionView?.reloadData()
            
            self.fetchSignForSentences()
//            var words = [String]()
//            for sentence in self.sentences {
//                for word in sentence.words {
//                    words.append(word.text)
//                }
//            }
//
//            SLSignStoreManager.shared.fetchSigns(words: words, completion: {
//                fetchReuslt, fetchError in
//
//                if let fetchReuslt = fetchReuslt {
//                    var signDict = [String : SLSign]()
//                    for ( _ , sign ) in fetchReuslt {
//                        signDict[sign.name] = sign
//                    }
//                    self.signDict = signDict
//                }
//            })
            
        }
    }
}

extension SLLiveTextViewController  : PlayerViewDelegate {
    func playerVideo(player: PlayerView, statusItemPlayer: PVItemStatus, error: Error?) {
        
    }
    
    func playerVideo(player: PlayerView, statusPlayer: PVStatus, error: Error?) {
        
    }
    func playerVideo(player: PlayerView, statusItemPlayer: PVStatus, error: Error?) {
        
    }
    func playerVideo(player: PlayerView, loadedTimeRanges: [PVTimeRange]) {
        
    }
    func playerVideo(player: PlayerView, duration: Double) {
        print("\(duration)")
        self.duration = duration
    }
    func playerVideo(player: PlayerView, currentTime: Double) {
        print("\(currentTime)")
        if let sliders = self.videoProgressSlider {
            for slider in sliders {
                slider.value = Float(currentTime / self.duration)
            }
        }
    }
    func playerVideo(player: PlayerView, rate: Float) {
        
    }
    func playerVideo(playerFinished player: PlayerView) {
        
    }
}


extension SLLiveTextViewController {
    func extractAudio(url : URL){
        // Create a composition
        let composition = AVMutableComposition()
        do {
            let sourceUrl = url
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        // Get url for output
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "temp.m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            
            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else {
                    print("failed")
                    return
                }
                print("\(outputUrl)")
                
                //let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: [])
                //self.present(activityViewController, animated: true, completion: nil)
                self.transcribe(url: outputURL)
                
            }
        }
    }
    
    func transcribe(url : URL){
        print("transcribe audio")
        AudioSpeechAnalyser.shared.delegate = self
        AudioSpeechAnalyser.shared.transcribeFile(url: url)
    }
}
