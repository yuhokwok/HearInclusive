//
//  SLRecordingManager.swift
//  HearInclusive
//
//  Created by SAME Team on 6/7/2022.
//

import Foundation
import CloudKit

class SLRecordingManager {
    
    static var shared = SLRecordingManager()
    
    var isRecording = false
    
    var currentIndex = 0
    
    var wordList : [String] = []
    //var repository : [String : [SLFrame]] = [:]
    var repository : [String : SLSign] = [:]
    
    var currentKey : String {
        return wordList[currentIndex]
    }
    
    func hasRecord(word : String) -> Bool {
        if let sign = repository[word]{
            return sign.frames.count > 0
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
            repository[word] = SLSign(name: word)
        }
    }
    
    func appendFrame(_ frame : SLFrame, with size : CGSize = .zero){
        let key = self.wordList[currentIndex]
        //self.repository[key]?.append(frame)
        self.repository[key]?.frames.append(frame)
        self.repository[key]?.baseDimension = size
    }
    
    func save(storeCompletitonHandler: (([CKRecord]) -> Void)?) {
//        print("save data")
//        for (key, sign) in repository{
//            self.save(name: key, sign: sign)
//        }
  
        
        //save to cludkit
        if let signs = Array(repository.values) as? [SLSign] {
            print("save to cloudkit")

            SLSignStoreManager.shared.storeSigns(signs: signs, storeCompletitonHandler: storeCompletitonHandler)
        }
        
//        print("save to firebase")
//        for (key, sign) in repository {
//            //self.save(name: key, frames: sign)
//            SLSignStoreManager.shared.storeSign(sign: sign, with: key)
//        }
    }
    
    func load(name : String) -> SLSign? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("slsigns/\(name).slsigns")
        
        if let data = try? Data(contentsOf: documentsDirectory) {
            if let sign = try? JSONDecoder().decode(SLSign.self, from: data) {
                return sign
            }
        }
        return nil
    }
    
    func save(name : String, sign : SLSign){
        print("save")
        guard hasRecord(word: name) == true else {
            return
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("slsigns/\(name).slsign")
        
        try? FileManager.default.removeItem(at: documentsDirectory)
        
        if let data = try? JSONEncoder().encode(sign) {
            print("savesave")
            try? data.write(to:documentsDirectory)
        }
    }
    
    func record(){
        isRecording = true
        let key = self.wordList[currentIndex]
        self.repository[key] = SLSign(name: key)
        self.repository[key]?.startTimeInterval = Date().timeIntervalSinceReferenceDate
    }
    
    func stop() {
        let key = self.wordList[currentIndex]
        self.repository[key]?.endTimeInterval = Date().timeIntervalSinceReferenceDate
        print("\(self.repository[key]?.duration)")
        isRecording = false
    }
}
