//
//  SLLiveTextViewController+Image.swift
//  Photo
//
//  Created by Yu Ho Kwok on 1/9/2022.
//

import UIKit
import Vision
import VisionKit

extension SLLiveTextViewController {
    func setupVision() {
        let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        request.recognitionLanguages = ["zh-hant", "zh-hants", "en"]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.05
        self.requests = [request]
    }
    
    func processForImage(url : URL) {
        DispatchQueue.main.async {
            
            self.setupVision()
            
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                    
                    
                    //let uiImage = UIImage(cgImage: image)
                    let uiImage = image //, scale: 1.0, orientation: .right)
                    
                    let imageSize = CGSize(width: uiImage.size.width, height: uiImage.size.height)
                    
                    let imageViewSize = self.imageView!.bounds.size
                    
                    let ratioImage = imageSize.width / imageSize.height
                    let ratioImageView = imageViewSize.width / imageViewSize.height
                    
                    let croppedRect : CGRect
                    if ratioImage < ratioImageView {
                        //size align to width
                        let destHeight = 1 / ratioImageView * imageSize.width
                        let yOffset = (imageSize.height - destHeight) / 2
                        
                        croppedRect = CGRect(x: 0, y: yOffset, width: imageSize.width, height: destHeight)  //CGRectMake(0, yOffset, imageSize.width, destHeight)
                    } else {
                        let destWidth = imageSize.height * ratioImageView
                        let xOffset = (imageSize.width - destWidth) / 2
                        //croppedRect = CGRectMake(xOffset, 0, destWidth, imageSize.height)
                        
                        croppedRect = CGRect(x: xOffset, y: 0, width: destWidth, height: imageSize.height)
                    }
                    
                    let croppedCGImage = uiImage.cgImage!.cropping(to: croppedRect)
                    let croppedUIImage = UIImage(cgImage: croppedCGImage!) //, scale: 1.0, orientation: .right)
                    
                    self.imageView.image = croppedUIImage
                    
                    
                    self.recognizeText(image: croppedUIImage)
                    
                }
            }
        }
    }
    
    func recognizeText(image : UIImage) {
        let requestOptions : [VNImageOption : Any] = [:]
        let imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!) //, orientation: .right, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    //handler
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let recognizedWords = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            let string = observation.topCandidates(1).first?.string
            let rectObs = VNRectangleObservation(boundingBox: observation.boundingBox)
            let recognizedWord = RecognizedWord(string: string, boundingBox: rectObs)
            return recognizedWord
        }
        
        
        
        print("\(recognizedWords)")
         //Process the recognized strings.
        //processResults(recognizedStrings)
        //print("\(recognizedStrings)")
        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            
            if recognizedWords.count > 0 {
                let view = UIView(frame: self.imageView.bounds)
                view.backgroundColor = UIColor(white: 0, alpha: 0.1)
                self.imageView.addSubview(view)
            }
            
            for i in 0..<recognizedWords.count {
                let region = recognizedWords[i].boundingBox
                self.drawTextBox(box: region, for: i)
            }
            
            for i in 0..<recognizedWords.count {
                self.addImageIcon(box: recognizedWords[i].boundingBox, for: i)
            }
        
            self.recognizgedWords = recognizedWords
            self.collectionView?.reloadData()
        }
        
    }
    
    func addImageIcon(box : VNRectangleObservation, for number : Int) {
        let xCoord = box.topLeft.x * imageView.frame.size.width
        let yCoord = (1 - box.topLeft.y) * imageView.frame.size.height
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.text = "\(number + 1)"
        label.backgroundColor = UIColor(white: 0, alpha: 0.9)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.font = UIFont.systemFont(ofSize: 12)
        label.center = CGPoint(x: xCoord, y: yCoord)
        label.clipsToBounds = true
        self.imageView.addSubview(label)
    }
    
    func drawTextBox(box: VNRectangleObservation, for number : Int) {
        
        guard let image = imageView.image else {
            return
        }
        

        let xCoord = box.topLeft.x * imageView.frame.size.width
        let yCoord = (1 - box.topLeft.y) * imageView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        
        let imgXCoord = box.topLeft.x * image.size.width
        let imgYCoord = (1 - box.topLeft.y) * image.size.height
        let imageWidth = (box.topRight.x - box.bottomLeft.x) * image.size.width
        let imageHeight = (box.topLeft.y - box.bottomLeft.y) * image.size.height
        
        let rect = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        let croppedRect = CGRect(x: imgXCoord, y: imgYCoord, width: imageWidth, height: imageHeight)
        let croppedImage = image.cgImage!.cropping(to: croppedRect)
        let croppedUIImage = UIImage(cgImage: croppedImage!)
        
        let croppedImageView = UIImageView(image: croppedUIImage)
        croppedImageView.frame = rect
        croppedImageView.clipsToBounds = true
        croppedImageView.layer.cornerRadius = 5

        croppedImageView.tag = number
        croppedImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.gestureRecognizted(gesture:))))
        imageView.addSubview(croppedImageView)
        
        imageView.isUserInteractionEnabled = true
        croppedImageView.isUserInteractionEnabled = true
    }
    
    
    @objc
    func gestureRecognizted(gesture : UITapGestureRecognizer){
        guard let gestureView = gesture.view else {
            return
        }
        
        self.playSection(section: gestureView.tag)
//        let indexPath = IndexPath(item: gestureView.tag, section: 0)
//        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
//        self.collectionView(self.collectionView!, didSelectItemAt: indexPath)
    }
    
    func playSection(section : Int){
        self.selectedSection = section
        
        DispatchQueue.main.async {
            self.player.play(scentences: [self.sentences[self.selectedSection]], signDict: self.signDict)
        }
    }
}
