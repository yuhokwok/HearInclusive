//
//  SwiftUI Speech.swift
//  Speech to Text
//
//  Created by Joel Joseph on 3/22/20.
//  Copyright © 2020 Joel Joseph. All rights reserved.
//

import Speech
import SwiftUI
import Foundation

public protocol SpeechManagerDelegate {
    func speech(_ manage : SpeechManager, result : String)
}

public class SpeechManager{
    
    var lastTriggeredWord = ""
    var delegate : SpeechManagerDelegate?
    
    init(){
        
        //Requests auth from User
        SFSpeechRecognizer.requestAuthorization{ authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                    case .authorized:
                        break

                    case .denied:
                        break
                    
                    case .restricted:
                        break
                      
                    case .notDetermined:
                        break
                      
                    default:
                        break
                }
            }
        }// end of auth request
        
        recognitionTask?.cancel()
        self.recognitionTask = nil

    }
    
    //func getButton()->SpeechButton{ // returns the button
    //    return button
    //}// end of get button
    
    func startRecording(){// starts the recording sequence
        
        
        print("start recording")
        // restarts the text
        outputText = "";
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        
        
        // try catch to start audio session
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }catch{
            print("ERROR: - Audio Session Failed!")
        }
        
        
        let inputNode = audioEngine.inputNode
        // Configure the microphone input and request auth
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do{
            try audioEngine.start()
        }catch{
            print("ERROR: - Audio Engine failed to start")
        }
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionRequest.requiresOnDeviceRecognition = false
        // Create a recognition task for the speech recognition session.
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest){ result, error in
            if (result != nil){
                self.outputText = (result?.transcriptions[0].formattedString)!
            }
            if let result = result{
                // Update the text view with the results.
                if result.isFinal {
                    print("clear triggered word")
                    self.lastTriggeredWord = ""
                }
                
                self.outputText = result.transcriptions[0].formattedString
                
                self.delegate?.speech(self, result: "\(self.outputText)")
            }
            if error != nil {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        }
    }// end of stop recording
    
    func stopRecording(){// end recording
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        
    }// restarts the variables
    
    
    func getSpeechStatus()->String{// gets the status of authorization
        
        switch authStat{
            
            case .authorized:
                return "Authorized"
            
            case .notDetermined:
                return "Not yet Determined"
            
            case .denied:
                return "Denied - Close the App"
            
            case .restricted:
                return "Restricted - Close the App"
            
            default:
                return "ERROR: No Status Defined"
    
        }// end of switch
        
    }// end of get speech status
    
    /* Variables **/
    @Published var isRecording:Bool = false
    //@Published var button = SpeechButton()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-hk"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let authStat = SFSpeechRecognizer.authorizationStatus()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    public var outputText:String = "";
    
    
}
