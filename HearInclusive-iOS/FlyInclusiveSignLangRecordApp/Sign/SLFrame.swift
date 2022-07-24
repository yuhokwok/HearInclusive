//
//  SLFrame.swift
//  HearInclusive
//
//  Created by SAME Team on 5/7/2022.
//

import Foundation
import CoreGraphics
import Vision

struct SLCloudKitFrame {
    var faceBoundingBox : SLRect
    var faceFeatures : [String : [SLPoint]]
    var bodyFeature : [String : SLPoint]
    var handFeatures : [[String : SLPoint]]
}

struct SLRect  {
    var origin : SLPoint
    var size : SLSize
    
    var cgRect : CGRect {
        return CGRect(origin: origin.cgPoint, size: size.cgSize)
    }
}

struct SLSize  {
    var width : NSNumber
    var height : NSNumber
    
    static var zero : SLSize {
        return SLSize(width: 0, height: 0)
    }
    
    var cgSize : CGSize {
        return CGSize(width: width.doubleValue, height: height.doubleValue)
    }
}

struct SLPoint  {
    var x : NSNumber
    var y : NSNumber
    
    var cgPoint : CGPoint {
        return CGPoint(x: x.doubleValue, y: y.doubleValue)
    }
}

struct SLFrame : Codable {
    //face, max 1 face, 64 points
    var faceBoundingBox : CGRect
    var faceFeatures : [String : [CGPoint]]
    //body, max 1 body - 17 points
    var bodyFeature : [String : CGPoint]
    
    
    //hand, max 2 hands - 21 points x 2 hands
    var handFeatures :[[String: CGPoint]]
    
    var isEmpty : Bool {
        return faceFeatures.keys.count == 0 && bodyFeature.keys.count == 0 && handFeatures.count == 0
    }
    
    var cloudKitFrame : SLCloudKitFrame {
        
        var faceFeaturesCloudKit : [String : [SLPoint]]  = [:]
        for (key, points) in faceFeatures {
            var pointsCloudKit = [SLPoint]()
            for point in points {
                pointsCloudKit.append(point.slPoint)
            }
            faceFeaturesCloudKit[key] = pointsCloudKit
        }
        
        var bodyFeaturesCloudKit : [String : SLPoint] = [:]
        for (key, point) in bodyFeature {
            bodyFeaturesCloudKit[key] = point.slPoint
        }
        
        
        var handFeaturesCloudKit : [[String : SLPoint]] = []
        for handFeature in handFeatures {
            var dict = [String : SLPoint]()
            for (key, point) in handFeature {
                dict[key] = point.slPoint
            }
            handFeaturesCloudKit.append(dict)
        }
        
        return SLCloudKitFrame(
            faceBoundingBox: faceBoundingBox.slRect,
            faceFeatures: faceFeaturesCloudKit,
            bodyFeature: bodyFeaturesCloudKit,
            handFeatures: handFeaturesCloudKit
        )
    }
}



extension CGPoint {
    var slPoint : SLPoint {
        return SLPoint(x: self.x as NSNumber, y: self.y as NSNumber)
    }
    
    var dict : [String : Any] {
        var dict : [String : Any] = [:]
        dict["x"] = NSNumber(value: x)
        dict["y"] = NSNumber(value: y)
        return dict
    }
}

extension CGSize {
    var slSize : SLSize {
        return SLSize(width: width as NSNumber, height: height as NSNumber)
    }
    
    var dict : [String : Any] {
        var dict : [String : Any] = [:]
        dict["width"] = NSNumber(value: width)
        dict["height"] = NSNumber(value: height)
        return dict
    }
}

extension CGRect {
    var slRect : SLRect {
        return SLRect(origin: origin.slPoint, size: size.slSize)
    }
    
    var dict : [String : Any] {
        var dict : [String : Any] = [:]
        dict["origin"] = origin.dict
        dict["size"] = size.dict
        return dict
    }
}
