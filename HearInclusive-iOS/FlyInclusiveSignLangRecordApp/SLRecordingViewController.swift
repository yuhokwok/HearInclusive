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
class SLRecordingViewController : UIViewController, UITextFieldDelegate, RPPreviewViewControllerDelegate {

    var imageViews : [UIImageView] = []

    
    let recorder = RPScreenRecorder.shared()
    
    
    @IBOutlet var cameraImage : UIImageView?
    @IBOutlet var cameraLabel : UILabel?
    
    @IBOutlet var textField : UITextField?
    @IBOutlet var statusLabel : UILabel?
    
    @IBOutlet var collectionView : UICollectionView?
    
    var words : [String] = ["我", "想", "食", "漢堡"]
    
    
    @IBOutlet var recordButton : UIButton?
    @IBOutlet var playButton : UIButton?
    @IBOutlet var switchCamerButton : UIButton?
    @IBOutlet var nextButton : UIButton?
    
    var isPlaybackMode = false {
        didSet {
            if isPlaybackMode == true {
                
                self.cameraLabel?.isEnabled = false
                
                self.nextButton?.isEnabled = SLRecordingManager.shared.wordList.count > 1
                self.switchCamerButton?.isEnabled = false
                self.playbackImageView.isHidden = false
                
                self.recordButton?.setImage(UIImage(systemName: "camera.fill"), for: .normal)
                
                cameraLabel?.text = "PLAYBACK"
                cameraImage?.image = UIImage(systemName: "play.rectangle.fill")
            } else {
                self.switchCamerButton?.isEnabled = true
                self.nextButton?.isEnabled = SLRecordingManager.shared.wordList.count > 1
                let currentKey = SLRecordingManager.shared.currentKey
                self.playButton?.isEnabled = SLRecordingManager.shared.hasRecord(word: currentKey)
                
                self.playbackImageView.isHidden = true
                
                self.recordButton?.setImage(UIImage(systemName: "circle.fill"), for: .normal)
                
                cameraImage?.image = UIImage(systemName: "camera.fill")
                cameraLabel?.text = (videoCapture.cameraPostion == .front) ? "FRONT CAMERA" : "BACK CAMERA"
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SLPlayer.shared.delegate = self
        
        //clear old records
        SLRecordingManager.shared.clear()
        
        //prepare new for new words
        SLRecordingManager.shared.prepare(for: self.words)
        
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = false
        
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

        let indexPath = IndexPath(item: SLRecordingManager.shared.currentIndex, section: 0)
        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        let cell = self.collectionView(self.collectionView!, cellForItemAt: indexPath)
        cell.isSelected = true
        self.collectionView(self.collectionView!, didSelectItemAt: indexPath)
        
        if SLRecordingManager.shared.wordList.count > 1 {
            self.nextButton?.isEnabled = true
        } else {
            self.nextButton?.isEnabled = false
            self.nextButton?.tintColor = .lightGray
        }
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

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func nextButtonClicked(_ sender : Any){
        let index = SLRecordingManager.shared.next()
        let indexPath = IndexPath(item: index, section: 0)

        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        let cell = self.collectionView(self.collectionView!, cellForItemAt: indexPath)
        cell.isSelected = true
        self.collectionView(self.collectionView!, didSelectItemAt: indexPath)
    }
    
    @IBAction func playButtonClicked(_ sender : Any){
        guard let sign = SLRecordingManager.shared.repository[SLRecordingManager.shared.currentKey] else {
            return
        }
        
        isPlaybackMode = true
        SLPlayer.shared.play(frames: sign.frames)
    }
    
    @IBAction func recordButtonClick(_ sender : Any){
        
        if isPlaybackMode == true {
            SLPlayer.shared.stop()
            isPlaybackMode = false
            return
        }
        
        if SLRecordingManager.shared.isRecording {
            self.switchCamerButton?.isEnabled = true
            self.nextButton?.isEnabled = SLRecordingManager.shared.wordList.count > 1
            let currentKey = SLRecordingManager.shared.currentKey
            self.playButton?.isEnabled = SLRecordingManager.shared.hasRecord(word: currentKey)
            
            SLRecordingManager.shared.stop()
            UIView.animate(withDuration: 0.3, animations: {
                self.recordButton?.backgroundColor = #colorLiteral(red: 0.08724250644, green: 0.192432791, blue: 0.4109585583, alpha: 1)
                let image = UIImage(systemName: "circle.fill")
                self.recordButton?.setImage(image, for: .normal)
            })
            
            
        } else {
            self.switchCamerButton?.isEnabled = false
            self.nextButton?.isEnabled = SLRecordingManager.shared.wordList.count > 1
            self.playButton?.isEnabled = false
            SLRecordingManager.shared.record()
            UIView.animate(withDuration: 0.3, animations: {
                self.recordButton?.backgroundColor = #colorLiteral(red: 0.7379922271, green: 0.1371690035, blue: 0.1375864148, alpha: 1)
                let image = UIImage(systemName: "square.fill")
                self.recordButton?.setImage(image, for: .normal)
            })
        }
        
        return
        
        guard textField!.text?.isEmpty == false else {
            self.statusLabel?.text = "The textfield is empty"
            return
        }
        
        //give up this part later on
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
    @IBOutlet weak var playbackImageView : UIImageView!
    
    
    var imageSize = CGSize.zero

    private let videoCapture = VideoCapture()
    
    private var currentFrame: CGImage?
    


    @IBAction func switchCamera(){
        self.videoCapture.flipCamera(completion: {
            error in
            
            DispatchQueue.main.async {
                
                if self.videoCapture.cameraPostion == .front {
                    self.cameraLabel?.text = "FRONT CAMERA"
                } else {
                    self.cameraLabel?.text = "BACK CAMERA"
                }
                
            }
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
            
            DispatchQueue.main.async {
                
                if self.videoCapture.cameraPostion == .front {
                    self.cameraLabel?.text = "FRONT CAMERA"
                } else {
                    self.cameraLabel?.text = "BACK CAMERA"
                }
                
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
        
        var bodyObseravation : VNRecognizedPointsObservation? = nil
        if let _bodyObservations = self.bodyObservations {
            if _bodyObservations.count > 0 {
                bodyObseravation = _bodyObservations[0]
            }
        }
        
        
        guard let frame = SLFrame.getFrame(body: bodyObseravation,
                                           hands: handObservations,
                                           faces: faceLandmarks) else {
            print("no frame")
            return
        }
        
        if SLRecordingManager.shared.isRecording == true {
            if frame.isEmpty == false {
                print("append frame")
                SLRecordingManager.shared.appendFrame(frame, with: imageSize)
            }
        }
        
        guard let currentFrame = self.currentFrame else {
            return
        }
            
        
        //print("render for frame")
        let image = currentFrame.render(for: frame)
        
        DispatchQueue.main.async {
            //print("set image")
            self.previewImageView.image = image
        }
        
        return
        
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
            let preprocessImage = UIImage(cgImage: currentFrame) //, scale: 1.0, orientation: .right)
            
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

extension SLRecordingViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath)
        if let extractedWorldCell = cell as? ExtractedWordCell {
            extractedWorldCell.label?.text = SLRecordingManager.shared.wordList[indexPath.item]
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SLRecordingManager.shared.wordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SLRecordingManager.shared.currentIndex = indexPath.item
        
        if SLRecordingManager.shared.isRecording  {
            let key = SLRecordingManager.shared.currentKey
            SLRecordingManager.shared.repository[key]?.frames.removeAll()
        } else {
            let word = SLRecordingManager.shared.wordList[indexPath.row]
            self.playButton?.isEnabled = SLRecordingManager.shared.hasRecord(word: word)
        }
    }
}

// MARK: - VideoCaptureDelegate

extension SLRecordingViewController : VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {

        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        estimation(image)
    }
}


extension SLRecordingViewController : SLPlayerDelegate {
    func player(_ player: SLPlayer, didOutputFrame frame: SLFrame) {
        print("output frame")
        
        let image = UIImage(named: "base")
        if let outputImage = image?.cgImage?.render(for: frame) {
            self.playbackImageView.image = outputImage
        }
    }
    
    func playerDidEndPlayback(_ player: SLPlayer) {
        print("ended")
        
    }
    
    func player(_ player: SLPlayer, startPlaying word: String, at index: Int) {
        
    }
}
