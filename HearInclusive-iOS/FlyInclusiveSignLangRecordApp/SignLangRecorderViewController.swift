//
//  ViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by Mable Hin on 14/11/2021.
//

import UIKit

import UIKit
import Vision
import ReplayKit
class SignLangRecorderViewController : UIViewController, UITextFieldDelegate, RPPreviewViewControllerDelegate {

    var imageViews : [UIImageView] = []

    
    let recorder = RPScreenRecorder.shared()
    
    
    @IBOutlet var textField : UITextField?
    @IBOutlet var statusLabel : UILabel?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func recordButtonClick(_ sender : Any){
        
        guard textField!.text?.isEmpty == false else {
            self.statusLabel?.text = "The textfield is empty"
            return
        }
        
        if recorder.isRecording {
            
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var documentsDirectory = paths[0]
            documentsDirectory.appendPathComponent("signs/\(textField!.text!).mp4")
            
            try? FileManager.default.removeItem(at: documentsDirectory)
            
            recorder.stopRecording(withOutput: documentsDirectory, completionHandler: {
                error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.statusLabel?.text = "Error, please try again"
                    } else
                    {
                        self.statusLabel?.text = "Record completed"
                    }
                }
            })
            
            /*
            recorder.stopRecording(handler: {
                previewVC, error in
                
                if error != nil {
                    self.statusLabel?.text = "Error, please try again"
                } else
                {
                    self.statusLabel?.text = "Record completed"
                    guard let previewVC = previewVC else {
                        return
                    }
                    
                    
                    previewVC.popoverPresentationController?.sourceView = self.view
                    previewVC.popoverPresentationController?.sourceRect = self.view.bounds
                    previewVC.previewControllerDelegate = self
                    self.present(previewVC, animated: true, completion: nil)


                }
            })
             */
        } else {
            self.statusLabel?.text = "Recording"
            recorder.startRecording(handler: {
                error in
                if error != nil {
                    self.statusLabel?.text = "Error, please try again"
                }
            })
            //recorder.startCapture(handler: nil, completionHandler: nil)
        }
    }
    
    @IBAction func gesture(_ gesture : UIGestureRecognizer){
        //print("yo")
        if self.navigationController?.isNavigationBarHidden == true {
            //self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            //self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var previewImageView : UIImageView!
    
    
    var imageSize = CGSize.zero

    private let videoCapture = VideoCapture()
    
    private var currentFrame: CGImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        setupAndBeginCapturingVideoFrames()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.previewImageView.backgroundColor = .white
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }


    @IBAction func switchCamera(){
        self.videoCapture.flipCamera(completion: {
            error in
        })
    }

    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
        }
    }


 
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }
    

    func estimation(_ cgImage:CGImage) {
        imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        //VNImageRequestHandler(cgImage: cgImage)

        
        
        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        let handPoseRequest =  VNDetectHumanHandPoseRequest(completionHandler: handPoseHandler)
        handPoseRequest.maximumHandCount = 2
        
        let facelandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: faceLandmarkHandler)
        
        do {
            
            // Perform the body pose-detection request.
            try requestHandler.perform([request, handPoseRequest, facelandmarksRequest])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }
    
    var handObservations : [VNRecognizedPointsObservation]?
    var bodyObservations : [VNRecognizedPointsObservation]?
    var faceLandmarks : [VNFaceObservation]?
    
    func faceLandmarkHandler(request: VNRequest, error: Error?){
        guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
            let results = landmarksRequest.results as? [VNFaceObservation] else {
                return
        }
        
        self.faceLandmarks = results
//        // Perform all UI updates (drawing) on the main queue, not the background queue on which this handler is being called.
//        DispatchQueue.main.async {
//            //self.drawFaceObservations(results)
//            self.delegate?.analyzer(self, didDetectFaceLandmarks: results, at: timestamp)
//        }
    }
    
    func handPoseHandler(request:  VNRequest, error: Error?){
        guard let observations = request.results as? [VNRecognizedPointsObservation] else {
            self.handObservations = nil
            return
        }
        self.handObservations = observations
    }
    
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedPointsObservation] else {
                    self.bodyObservations = nil
                    return
                }
        self.bodyObservations = observations

        // Process each observation to find the recognized body pose points.
        if observations.count == 0 {
            guard let currentFrame = self.currentFrame else {
                return
            }
            let image = UIImage(cgImage: currentFrame)
            DispatchQueue.main.async {
                self.previewImageView.image = false ? image : nil
            }
        } else {

            //provide observations information to runtime
            
            //special version
            guard let currentFrame = self.currentFrame else {
                return
            }
            let preprocessImage = UIImage(cgImage: currentFrame)
            
            let dict = process(observations[0]) ?? [ : ]
            
            var handDicts = [[String : CGPoint]]()
            for handObservation in self.handObservations ?? [] {
                let handDict = process(handObservation) ?? [:]
               // print("handDict: \(handDict)")
                handDicts.append(handDict)
            }
            
            let image = currentFrame.drawLines(dict: dict, handDicts: handDicts, faceObservations: faceLandmarks,  isShowCamera:  false)
            
            DispatchQueue.main.async {
                self.previewImageView.image = image
            }
        }
        
    }

    
    func process(_ observation : VNRecognizedPointsObservation) -> [String : CGPoint]? {
        guard let recognizedPoints =
                try? observation.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all) else {
                    return [:]
        }
        
        var dict = [String:CGPoint]()
        for (key, point) in recognizedPoints {
            if point.confidence > 0 {
                dict[key.rawValue] = VNImagePointForNormalizedPoint(point.location,
                                                                Int(imageSize.width),
                                                                Int(imageSize.height))
            }
        }
        return dict
    }
    
    func processObservation(_ observation: VNRecognizedPointsObservation) -> [CGPoint]? {
        
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all) else {
            return []
        }
        
        
        let imagePoints: [CGPoint] = recognizedPoints.values.compactMap {
            guard $0.confidence > 0 else { return nil }
            
            print($0.identifier.rawValue)

            return VNImagePointForNormalizedPoint($0.location,
                                                  Int(imageSize.width),
                                                  Int(imageSize.height))
        }
        
        return imagePoints
    }

}



// MARK: - VideoCaptureDelegate

extension SignLangRecorderViewController : VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {

        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        estimation(image)
    }
}
