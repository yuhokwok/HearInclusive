//
//  SLFrame+Extraction.swift
//  HearInclusive
//
//  Created by SAME Team on 23/7/2022.
//

import Foundation
import CoreGraphics
import Vision


extension SLFrame{
    static let openKeys = ["leftEyebrow", "rightEyebrow", "faceContour", "noseCrest", "medianLine"]
    static let closedKeys = ["leftEye", "rightEye", "outerLips", "innerLips", "nose"]
    
    static func getFrame(body: VNRecognizedPointsObservation?, hands : [VNRecognizedPointsObservation]?, faces : [VNFaceObservation]?) -> SLFrame? {
        
        
        
        //extract body
        var bodyDict = [String: CGPoint]()
        if let recognizedPoints = try? body?.recognizedPoints(forGroupKey: .all) {
            for (key, point) in recognizedPoints {
                bodyDict[key.rawValue] = CGPoint(x: point.x, y: point.y)
            }
        }
        //print("body dict: \(bodyDict)")
        
        var handDicts = [[String: CGPoint]]()
        //extract hands
        if let hands = hands {
            if hands.count > 0 && hands.count < 3 {
                for i in 0..<hands.count {
                    var handDict = [String: CGPoint]()
                    if let recognizedPoints = try? hands[i].recognizedPoints(forGroupKey: .all) {
                        for (key, point) in recognizedPoints {
                            handDict[key.rawValue] = CGPoint(x: point.x, y: point.y)
                        }
                    }
                    handDicts.append(handDict)
                }
            }
        }
        //print("hand dicts: \(handDicts)")

        //extract faces
        var faceFeatures = [String:[CGPoint]]()
        var boundingBox = CGRect.zero
        //extract hands
        if let faces = faces {
            if faces.count > 0 {
                let face = faces[0]
                
                if let landmarks  = face.landmarks {
                    
                    boundingBox = face.boundingBox
                    
                    var keys = SLFrame.openKeys
                    let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                        landmarks.leftEyebrow,
                        landmarks.rightEyebrow,
                        landmarks.faceContour,
                        landmarks.noseCrest,
                        landmarks.medianLine
                    ]
                    
                    
                    for i in 0..<openLandmarkRegions.count {
                        var facePoints = [CGPoint]()
                        if let openLandmarkRegion = openLandmarkRegions[i] {
                            for point in openLandmarkRegion.normalizedPoints {
                                facePoints.append(point)
                            }
                        }
                        faceFeatures[keys[i]] = facePoints
                    }

                    keys = SLFrame.closedKeys
                    // Draw eyes, lips, and nose as closed regions.
                    let closedLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                        landmarks.leftEye,
                        landmarks.rightEye,
                        landmarks.outerLips,
                        landmarks.innerLips,
                        landmarks.nose
                    ]
                    
                    for i in 0..<closedLandmarkRegions.count {
                        
                        var facePoints = [CGPoint]()
                        if let closedLandmarkRegion = closedLandmarkRegions[i] {
                            for point in closedLandmarkRegion.normalizedPoints {
                                facePoints.append(point)
                            }
                        }
                        faceFeatures[keys[i]] = facePoints
                    }
                }
                
            }
        }
        let frame = SLFrame(faceBoundingBox: boundingBox,
                            faceFeatures: faceFeatures,
                            bodyFeature: bodyDict,
                            handFeatures: handDicts)
        return frame
    }
}
