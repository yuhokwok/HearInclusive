//
//  SpeechAudio.swift
//  Photo
//
//  Created by SAME Team on 21/8/2022.
//

//import Foundation
import Speech

protocol AudioSpeechAnalyserDelegate {
    func audioSpeechAnalyser(_ analyser : AudioSpeechAnalyser, didOutput text : String, isFinal : Bool)
}

class AudioSpeechAnalyser {
    static var shared = AudioSpeechAnalyser()
    
    var delegate : AudioSpeechAnalyserDelegate?
    
    func transcribeFile(url: URL) {

      // 1
      guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-hk")) else {
        print("Speech recognition not available for specified locale")
        return
      }
        
        

      if !recognizer.isAvailable {
        print("Speech recognition not currently available")
        return
      }
      
      // 2
      //updateUIForTranscriptionInProgress()
      let request = SFSpeechURLRecognitionRequest(url: url)
      
        request.shouldReportPartialResults = true
        
        request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        if (recognizer.supportsOnDeviceRecognition){
            print("on device")
        } else {
            print("not on device")
        }
        if #available(iOSApplicationExtension 16, *) {
            request.addsPunctuation = true
            print("auto punctuation")
        } else {
            // Fallback on earlier versions
        }
        
      // 3
      recognizer.recognitionTask(with: request) {
        [unowned self] (result, error) in
        guard let result = result else {
          print("There was an error transcribing that file")
          return
        }
        
          self.delegate?.audioSpeechAnalyser(self,
                                             didOutput: result.bestTranscription.formattedString,
                                             isFinal: result.isFinal)
          
//        // 4
//        if result.isFinal {
//          //self.updateUIWithCompletedTranscription(
//            DispatchQueue.main.async {
//                print("\(result.bestTranscription.formattedString)")
//            }
//        }
      }
    }
}
