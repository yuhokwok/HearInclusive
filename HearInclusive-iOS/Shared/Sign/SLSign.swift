//
//  SLSign.swift
//  HearInclusive
//
//  Created by SAME Team on 5/7/2022.
//

import Foundation


struct SLSign : Codable {

    var name : String
    
    var startTimeInterval : TimeInterval = 0
    var endTimeInterval : TimeInterval = 0
    
    var baseDimension = CGSize.zero
    
    var collection : String = "hksl"
    
    var frames : [SLFrame] = []
    
    var duration : TimeInterval {
        return endTimeInterval - startTimeInterval
    }
    
    var previewFrame : SLFrame? {
        let count = frames.count / 2
        if count < frames.count {
            let frame = frames[count]
            return frame
        }
        return nil
    }
    
    var jsonData : Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return nil
        }
    }
    
    var jsonString : String? {
        guard let data = self.jsonData else {
            return nil
        }
        
        if let string = String(data : data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    var dictionary : [String : Any]? {
        guard let data = self.jsonData else {
            return nil
        }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                print("\(dict)")
                return dict
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    static func load(jsonData : Data) -> SLSign? {
        do {
            return try JSONDecoder().decode(SLSign.self, from: jsonData)
        } catch {
            return nil
        }
    }

}
