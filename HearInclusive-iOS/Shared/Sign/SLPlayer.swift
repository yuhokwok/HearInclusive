//
//  SLPlayer.swift
//  HearInclusive
//
//  Created by SAME Team on 5/7/2022.
//

import Foundation


protocol SLPlayerDelegate {
    func player(_ player : SLPlayer, didOutputFrame frame : SLFrame)

    func player(_ player : SLPlayer, startPlaying word : String, at index : Int)
    //optional func player(_ player : SLPlayer, endPlaying word : String, at index : Int)
    
    func playerDidEndPlayback(_ player : SLPlayer)
}

class SLPlayer {
    static let shared = SLPlayer()
    
    var delegate : SLPlayerDelegate?
    
    var timer : Timer?
    
    
    var currentQueueIndex = 0
    var currentFrameIndex = 0
    
    var frames : [SLFrame]?
    
    var signDict : [String : SLSign] = [:]

    var queue : [String] = []
    
    var isPause = false
    var isPlayering = false
    
    func play(scentences : [NLPSentence], signDict : [String : SLSign]) {
        isPlayering = true
        isPause = false
        queue.removeAll()
        self.signDict = signDict
        for scentence in scentences {
            for word in scentence.words {
                self.queue.append(word.text)
            }
        }
        self.playQueue()
    }
    
    func playQueue() {
        currentQueueIndex = 0
        currentFrameIndex = 0
        
        let word = queue[currentQueueIndex]
        if let frames = signDict[word]?.frames {
            self.delegate?.player(self, startPlaying: word, at: currentQueueIndex)
            self.play(frames: frames)
        } else {
            print("無此字")
            playNextInQuene()
        }
    }
    
    func playNextInQuene() {
        self.timer?.invalidate()
        self.currentQueueIndex += 1
        
        if self.currentQueueIndex >= queue.count {
            //ended
            self.stop()
            return
        }
        
        let word = queue[currentQueueIndex]
        if let frames = signDict[word]?.frames {
            self.delegate?.player(self, startPlaying: word, at: currentQueueIndex)
            self.play(frames: frames)
        } else {
            self.delegate?.player(self, startPlaying: word, at: currentQueueIndex)
            self.playNextInQuene()
        }
    }
    
    func play(scenetence : SLSentence) {
        
    }
    
    func play(frames : [SLFrame]) {
        
        currentFrameIndex = 0
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        if frames.count == 0 {
            playNextInQuene()
            return
        }
        self.frames = frames
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: {
            timer in
            
            let frame = self.frames![self.currentFrameIndex]
            self.delegate?.player(self, didOutputFrame: frame)
            
            self.currentFrameIndex += 1
            if self.currentFrameIndex == self.frames!.count {
                
                print("try to play next in queue")
                self.playNextInQuene()
                
            }
        })
    }
    
    func pause() {
        isPause = true
        isPlayering = false
        timer?.invalidate()

    }
    
    func play(){
        
        if isPause == true {
            isPause = false
            isPlayering = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: {
                timer in
                
                let frame = self.frames![self.currentFrameIndex]
                self.delegate?.player(self, didOutputFrame: frame)
                
                self.currentFrameIndex += 1
                if self.currentFrameIndex == self.frames!.count {
                    
                    print("try to play next in queue")
                    self.playNextInQuene()
                    
                }
            })
            
            return
        }
        
        guard let frames = self.frames else {
            return
        }
        self.play(frames: frames)
    }
    
    func stop() {
        isPause = false
        isPlayering = false
        currentFrameIndex = 0
        timer?.invalidate()
        self.delegate?.playerDidEndPlayback(self)
    }
}
