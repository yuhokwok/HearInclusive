//
//  CGImageExt.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by Mable Hin on 14/11/2021.
//

import Foundation
import CoreGraphics
import UIKit
import Vision

extension CGImage {
    

    func drawLines(dict : [String : CGPoint], handDicts : [[String : CGPoint]]?, faceObservations : [VNFaceObservation]?, isShowCamera : Bool) -> UIImage? {
        
        //print(dict.keys)
        
        let pairs = [
                    //["right_ear_joint", "right_eye_joint"],
                    //["left_ear_joint", "left_eye_joint"],
                    //["right_eye_joint", "head_joint"],
                    //["left_eye_joint", "head_joint"],
                    //["head_joint", "neck_1_joint"],
                    
                    ["neck_1_joint", "right_shoulder_1_joint"],
                    ["right_shoulder_1_joint", "right_forearm_joint"],
                    ["right_hand_joint", "right_forearm_joint"],
                    
                    ["neck_1_joint", "left_shoulder_1_joint"],
                    ["left_shoulder_1_joint", "left_forearm_joint"],
                    ["left_hand_joint", "left_forearm_joint"],
        
                    ["neck_1_joint", "root"],
                    
                    // ["root", "right_upLeg_joint"],
                   // ["right_upLeg_joint", "right_leg_joint"],
                   // ["right_leg_joint", "right_foot_joint"],
                    
                   // ["root", "left_upLeg_joint"],
                   // ["left_upLeg_joint", "left_leg_joint"],
                   // ["left_leg_joint", "left_foot_joint"],
                    
                    
        ]
        
        let handPairs = [
                        ["VNHLKWRI", "VNHLKTCMC"],
                        ["VNHLKTCMC", "VNHLKTMP"],
                        ["VNHLKTMP", "VNHLKTIP"],
                        ["VNHLKTIP", "VNHLKTTIP"],

                        ["VNHLKWRI", "VNHLKPMCP"],
                        ["VNHLKPMCP", "VNHLKPPIP"],
                        ["VNHLKPPIP", "VNHLKPDIP"],
                        ["VNHLKPDIP", "VNHLKPTIP"],

                        ["VNHLKWRI", "VNHLKMMCP"],
                        ["VNHLKMMCP", "VNHLKMPIP"],
                        ["VNHLKMPIP", "VNHLKMDIP"],
                        ["VNHLKMDIP", "VNHLKMTIP"],
                        
                        ["VNHLKWRI", "VNHLKRMCP"],
                        ["VNHLKRMCP", "VNHLKRPIP"],
                        ["VNHLKRPIP", "VNHLKRDIP"],
                        ["VNHLKRDIP", "VNHLKRTIP"],
                        
                        ["VNHLKWRI", "VNHLKIMCP"],
                        ["VNHLKIMCP", "VNHLKIPIP"],
                        ["VNHLKIPIP", "VNHLKIDIP"],
                        ["VNHLKIDIP", "VNHLKITIP"]
                    ]
        
        let color = #colorLiteral(red: 0.4232858121, green: 0.4547516704, blue: 0.9486059546, alpha: 1)
        
        //draw line
        let cntx = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent , bytesPerRow: 0, space: colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        
        cntx?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        if isShowCamera == false {
            cntx?.setFillColor(UIColor.white.cgColor)
            cntx?.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        cntx?.setStrokeColor(color.cgColor)
        cntx?.setLineWidth(4)
        cntx?.setLineCap(.round)
        for pair in pairs {
            if let point1 = dict[pair[0]], let point2 = dict[pair[1]] {
                cntx?.move(to: point1)
                cntx?.addLine(to: point2)
            }
            cntx?.strokePath()
        }
        
        
        
        
        for dict in handDicts ?? [] {
            
            cntx?.setStrokeColor(color.cgColor)
            cntx?.setLineWidth(4)
            cntx?.setLineCap(.round)
            
            for pair in handPairs {
                if let point1 = dict[pair[0]], let point2 = dict[pair[1]] {
                    cntx?.move(to: point1)
                    cntx?.addLine(to: point2)
                    //print("draw")
                }
                cntx?.strokePath()
            }
        }
        
        for dict in handDicts ?? [] {
            //draw points
            for (_, point) in dict {
                //cntx?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
                cntx?.setFillColor(color.cgColor)
                cntx?.addArc(center: point, radius: 4, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
                cntx?.drawPath(using: .fill)
            }
        }
        
        //draw points
        for (_, point) in dict {
            //cntx?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
            cntx?.setFillColor(color.cgColor)
            cntx?.addArc(center: point, radius: 4, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
            cntx?.drawPath(using: .fill)
        }
        
        if let faceObservations = faceObservations {
            
            let faceLandmarksPath = CGMutablePath()
            
            for faceObservation in faceObservations {
                self.addIndicators(faceLandmarksPath: faceLandmarksPath,
                                   for: faceObservation,
                                   for: CGSize(width: width, height: height))
            }
            
            
            cntx?.setStrokeColor(color.cgColor)
            cntx?.setLineWidth(4)
            cntx?.setLineCap(.round)
            cntx?.beginPath()
            cntx?.addPath(faceLandmarksPath)
            cntx?.strokePath()
            
        }
        
        let _cgim = cntx?.makeImage()
        if let cgi = _cgim {
            let img = UIImage(cgImage: cgi)
            return img
        }
                
        return nil
    }
    
    fileprivate func addIndicators(faceLandmarksPath: CGMutablePath, for faceObservation: VNFaceObservation, for size : CGSize) {
        let displaySize = size
        
            
        let faceBounds = VNImageRectForNormalizedRect(faceObservation.boundingBox, Int(displaySize.width), Int(displaySize.height))
        
        if let landmarks = faceObservation.landmarks {
            // Landmarks are relative to -- and normalized within --- face bounds
            let affineTransform = CGAffineTransform(translationX: faceBounds.origin.x, y: faceBounds.origin.y)
                .scaledBy(x: faceBounds.size.width, y: faceBounds.size.height)
            
            // Treat eyebrows and lines as open-ended regions when drawing paths.
            let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
                landmarks.noseCrest,
                landmarks.medianLine
            ]
            for openLandmarkRegion in openLandmarkRegions where openLandmarkRegion != nil {
                self.addPoints(in: openLandmarkRegion!, to: faceLandmarksPath, applying: affineTransform, closingWhenComplete: false)
            }
            
            // Draw eyes, lips, and nose as closed regions.
            let closedLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.innerLips,
                landmarks.nose
            ]
            for closedLandmarkRegion in closedLandmarkRegions where closedLandmarkRegion != nil {
                self.addPoints(in: closedLandmarkRegion!, to: faceLandmarksPath, applying: affineTransform, closingWhenComplete: true)
            }
        }
    }
    
    fileprivate func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D, to path: CGMutablePath, applying affineTransform: CGAffineTransform, closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount
        if pointCount > 1 {
            let points: [CGPoint] = landmarkRegion.normalizedPoints
            path.move(to: points[0], transform: affineTransform)
            path.addLines(between: points, transform: affineTransform)
            if closePath {
                path.addLine(to: points[0], transform: affineTransform)
                path.closeSubpath()
            }
        }
    }
    
    func drawPoints(points:[CGPoint]) -> UIImage? {
        
        let cntx = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent , bytesPerRow: 0, space: colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        cntx?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        for point in points {
            cntx?.setFillColor(red: 0, green: 1, blue: 0, alpha: 1)
            cntx?.addArc(center: point, radius: 3, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
            cntx?.drawPath(using: .fill)

        }
        let _cgim = cntx?.makeImage()
        if let cgi = _cgim {
            let img = UIImage(cgImage: cgi)
            return img
        }
        return nil
    }
}
