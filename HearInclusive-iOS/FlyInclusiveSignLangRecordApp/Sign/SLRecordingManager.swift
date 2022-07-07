//
//  SLRecordingManager.swift
//  HearInclusive
//
//  Created by SAME Team on 6/7/2022.
//

import Foundation


class SLRecordingManager {
    
    static var shared = SLRecordingManager()
    
    var isRecording = false
    
    var currentIndex = 0
    
    var wordList : [String] = []
    var repository : [String : [SLFrame]] = [:]
    
    var currentKey : String {
        return wordList[currentIndex]
    }
    
    func hasRecord(word : String) -> Bool {
        if let array = repository[word]{
            return array.count > 0
        }
        return false
    }
    
    func next() -> Int {
        currentIndex += 1
        if currentIndex == wordList.count {
            currentIndex = 0
        }
        return currentIndex
    }
    
    func clear(){
        currentIndex = 0
        self.isRecording = false
        self.wordList.removeAll()
        self.repository.removeAll()
    }
    
    func prepare(for wordList : [String]) {
        self.wordList = wordList
        for word in wordList {
            repository[word] = []
        }
    }
    
    func appendFrame(_ frame : SLFrame){
        let key = self.wordList[currentIndex]
        self.repository[key]?.append(frame)
    }
    
    func save() {
        print("save data")
        for (key, frames) in repository{
            self.save(name: key, frames: frames)
        }
    }
    
    func load(name : String) -> [SLFrame]? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("slframes/\(name).slframes")
        
        if let data = try? Data(contentsOf: documentsDirectory) {
            if let frames = try? JSONDecoder().decode([SLFrame].self, from: data) {
                return frames
            }
        }
        return nil
    }
    
    func save(name : String, frames : [SLFrame]){
        print("save")
        guard hasRecord(word: name) == true else {
            return
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("slframes/\(name).slframes")
        
        try? FileManager.default.removeItem(at: documentsDirectory)
        
        if let data = try? JSONEncoder().encode(frames) {
            print("savesave")
            try? data.write(to:documentsDirectory)
        }
    }
    
    func record(){
        isRecording = true
        let key = self.wordList[currentIndex]
        self.repository[key] = []
    }
    
    func stop() {
        isRecording = false
    }
}
