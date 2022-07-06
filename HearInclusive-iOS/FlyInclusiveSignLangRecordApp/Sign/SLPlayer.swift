//
//  SLPlayer.swift
//  HearInclusive
//
//  Created by Yu Ho Kwok on 5/7/2022.
//

import Foundation


protocol SLPlayerDelegate {
    func player(_ player : SLPlayer, didOutputFrame frame : SLFrame)
    func playerDidEndPlayback(_ player : SLPlayer)
}

class SLPlayer {
    static let shared = SLPlayer()
    
    var delegate : SLPlayerDelegate?
    
    var timer : Timer?
    
    var currentFrameIndex = 0
    
    var frames : [SLFrame]?
    
    func play(frames : [SLFrame]) {
        
        currentFrameIndex = 0
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        if frames.count == 0 {
            return
        }
        self.frames = frames
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: {
            timer in
            
            let frame = self.frames![self.currentFrameIndex]
            self.delegate?.player(self, didOutputFrame: frame)
            
            self.currentFrameIndex += 1
            if self.currentFrameIndex == self.frames!.count {
                self.stop()
            }
        })
    }
    
    func play(){
        guard let frames = self.frames else {
            return
        }
        self.play(frames: frames)
    }
    
    func stop() {
        currentFrameIndex = 0
        timer?.invalidate()
        self.delegate?.playerDidEndPlayback(self)
    }
}
