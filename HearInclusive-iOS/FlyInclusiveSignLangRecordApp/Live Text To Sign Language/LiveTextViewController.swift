////
////  LiveTextViewController.swift
////  HearInclusive
////
////  Created by Yu Ho Kwok on 4/7/2022.
////
//
//import UIKit
//import VisionKit
//import Vision
//
////class MenuButton : UIButton {
////    @IBOutlet var associatedView : MenuButton?
////    override var isHighlighted: Bool {
////        didSet {
////            if let associatedViewHighlighted = self.associatedView?.isHighlighted {
////                if associatedViewHighlighted != isHighlighted {
////                    self.associatedView?.isHighlighted = isHighlighted
////                }
////            }
////        }
////    }
////}
//
////struct RecognizedWord {
////    let string : String?
////    let boundingBox : CGRect
////}
//
//class LiveTextViewController : UIViewController, ImageAnalysisInteractionDelegate {
//    let interaction = ImageAnalysisInteraction()
//    let configuration = ImageAnalyzer.Configuration([.text])
//    let analyzer = ImageAnalyzer()
//    
//    
//    private var requests = [VNRequest]()
//    
//    private let videoCapture = VideoCapture()
//    private var currentImage: UIImage?
//    
//    @IBOutlet var imageView : UIImageView?
//    
//    @IBOutlet var languageButton : MenuButton?
//    @IBOutlet var subLanguageButton : MenuButton?
//    
//    @IBOutlet var collectionView : UICollectionView?
//    
//    var menuItems: [UIAction] {
//        return [
//            UIAction(title: "Standard item", image: UIImage(systemName: "sun.max"), handler: { (_) in
//            }),
//            UIAction(title: "Disabled item", image: UIImage(systemName: "moon"), attributes: .disabled, handler: { (_) in
//            }),
//            UIAction(title: "Delete..", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
//            })
//        ]
//    }
//    
//    var demoMenu: UIMenu {
//        return UIMenu(title: "My menu", image: nil, identifier: nil, options: [], children: menuItems)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        interaction.delegate = self
//        if let imageViuew  = self.imageView {
//            imageView?.addInteraction(interaction)
//            imageView?.contentMode = .scaleAspectFill
//        }
//        
//        languageButton?.menu = demoMenu
//        languageButton?.showsMenuAsPrimaryAction = true
//        
//        subLanguageButton?.menu = demoMenu
//        subLanguageButton?.showsMenuAsPrimaryAction = true
//        
//        setupVision()
//    }
//    
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.setupAndBeginCapturingVideoFrames()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        videoCapture.stopCapturing()
//        {
//            
//        }
//        super.viewDidDisappear(animated)
//    }
//    
//    private func setupAndBeginCapturingVideoFrames() {
//        videoCapture.setUpAVCapture (preset: .hd1280x720) { error in
//            if let error = error {
//                print("Failed to setup camera with error \(error)")
//                return
//            }
//            
//            
//            
//            self.videoCapture.delegate = self
//            self.videoCapture.startCapturing()
//            
//            self.videoCapture.flipCamera(completion: {
//                error in
//            })
//            
//        }
//    }
//    
//    var isLive = false
//    var isProcessing = false
//}
//
//extension LiveTextViewController : VideoCaptureDelegate {
//    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
//        
//        guard let image = capturedImage else {
//            fatalError("Captured image is null")
//        }
//        
//        
//        guard isLive == false else {
//            return
//        }
//        
//        DispatchQueue.main.async {
//            //let uiImage = UIImage(cgImage: image)
//            let uiImage = UIImage(cgImage: image, scale: 1.0, orientation: .right)
//            self.currentImage = uiImage
//            self.imageView?.image = uiImage
//            
//        }
//        
//        
//        
//    }
//    
//    func liveTextAnalysis(image : UIImage) async {
//        self.isProcessing = true
//        do {
//            let analysis = try await analyzer.analyze(image, configuration: configuration)
//            interaction.analysis = analysis
//            interaction.preferredInteractionTypes = .textSelection
//            isProcessing = false
//        } catch let error {
//            print(error.localizedDescription)
//            isProcessing = false
//        }
//    }
//    
//    
//    @IBAction func toggleLiveText() {
//        if isLive == false {
//            isLive = true
//            
//            guard  isProcessing == false else {
//                return
//            }
//            
//            guard let uiImage = currentImage else {
//                return
//            }
//            Task.init {
//                await self.liveTextAnalysis(image: uiImage)
//            }
//        } else {
//            isLive = false
//        }
//    }
//    
//    func setupVision() {
//        let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
//        request.recognitionLanguages = ["zh-hant", "zh-hants", "en"]
//        self.requests = [request]
//    }
//    
//    func recognizeText(image : UIImage) {
//        let requestOptions : [VNImageOption : Any] = [:]
//        let imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: requestOptions)
//        
//        do {
//            try imageRequestHandler.perform(self.requests)
//        } catch {
//            print(error)
//        }
//    }
//    
//    //handler
//    func recognizeTextHandler(request: VNRequest, error: Error?) {
//        guard let observations =
//                request.results as? [VNRecognizedTextObservation] else {
//            return
//        }
//        
//        let recognizedStrings = observations.compactMap { observation in
//            // Return the string of the top VNRecognizedText instance.
//            let string = observation.topCandidates(1).first?.string
//            let recognizedWord = RecognizedWord(string: string, boundingBox: observation.boundingBox)
//            return recognizedWord
//        }
//        
//        // Process the recognized strings.
//        //processResults(recognizedStrings)
//        print("\(recognizedStrings)")
//    }
//    
//}
//
//extension LiveTextViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 15
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtractTextCell", for: indexPath)
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = Int.random(in: 50...140)
//        return CGSize(width: Double(width), height: 44)
//    }
//}
