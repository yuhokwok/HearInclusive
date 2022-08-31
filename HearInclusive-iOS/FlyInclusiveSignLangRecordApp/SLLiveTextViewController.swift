//
//  LiveTextViewController.swift
//  HearInclusive
//
//  Created by SAME Team on 4/7/2022.
//

import UIKit
import VisionKit
import Vision
import NaturalLanguage



class SLLiveTextViewController : UIViewController, SLPlayerDelegate {
    
    @IBOutlet var hiTabBar : HITabBar?
    @IBOutlet var browseBarButtonItem : UIBarButtonItem?
    
    
    
    private let videoCapture = VideoCapture()
    private var currentImage: UIImage?
    
    
    private var requests = [VNRequest]()
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var slImageView : UIImageView!
    
    @IBOutlet var languageButton : MenuButton?
    @IBOutlet var subLanguageButton : MenuButton?
    
    var tokenizer = NLTokenizer(unit: .word)
    
    @IBOutlet var collectionView : UICollectionView?
    var recognizgedWords = [RecognizedWord]() {
        didSet{
            //TODO
            var recognizedWords = [RecognizedWord]()
            for recognizgedWord in recognizgedWords {
                self.tokenizer.string = recognizgedWord.string!
                var words : [String] = []
                self.tokenizer.enumerateTokens(in: recognizgedWord.string!.startIndex..<recognizgedWord.string!.endIndex) {
                    range, attributes in
                    let substring = recognizgedWord.string![range]
                    words.append("\(substring)")
                    return true
                }
                for word in words {
                    
                    recognizedWords.append(RecognizedWord(string: word, boundingBox: recognizgedWord.boundingBox))
                }
            }
            recognizgedWords = recognizedWords
        }
    }
    
    
    @IBOutlet var playButton : UIButton?
    
    var player = SLPlayer()
    
    var menuItems: [UIAction] {
        return [
            UIAction(title: "Standard item", image: UIImage(systemName: "sun.max"), handler: { (_) in
            }),
            UIAction(title: "Disabled item", image: UIImage(systemName: "moon"), attributes: .disabled, handler: { (_) in
            }),
            UIAction(title: "Delete..", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { (_) in
            })
        ]
    }
    
    var demoMenu: UIMenu {
        return UIMenu(title: "My menu", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hiTabBar?.delegate = self
        
        self.player.delegate = self
        
        self.collectionView?.allowsSelection = true
        self.collectionView?.allowsMultipleSelection = false
        
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func playBtnClicked(){
        self.player.play()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupAndBeginCapturingVideoFrames()
        setupVision()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        videoCapture.stopCapturing()
        {
            
        }
        super.viewDidDisappear(animated)
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture (preset: .hd1920x1080) { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }
            
            
            
            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
            
            self.videoCapture.flipCamera(completion: {
                error in
            })
            
        }
    }
    
    var isLive = false
    var isProcessing = false
}

extension SLLiveTextViewController : VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }
        
        
        guard isLive == false else {
            return
        }
        
        DispatchQueue.main.async {
            //let uiImage = UIImage(cgImage: image)
            let uiImage = UIImage(cgImage: image) //, scale: 1.0, orientation: .right)
            
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
            
            //print("\(croppedUIImage.size)")
            self.imageView.image = croppedUIImage
            
            //print("\(ratioImage) vs \(ratioImageView)")
            
            self.currentImage = croppedUIImage
            //self.imageView?.image = uiImage
            
        }
    }
    
    @IBAction func toggleLiveText() {
        if isLive == false {
            isLive = true
            
            guard  isProcessing == false else {
                return
            }
            
            guard let uiImage = currentImage else {
                return
            }
            
            self.recognizeText(image: uiImage)
            
        } else {
            isLive = false
            for subviews in self.imageView.subviews {
                subviews.removeFromSuperview()
            }
        }
    }
    
    func setupVision() {
        let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        request.recognitionLanguages = ["zh-hant", "zh-hants", "en"]
        request.usesLanguageCorrection = true
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.05
        self.requests = [request]
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
        
        let indexPath = IndexPath(item: gestureView.tag, section: 0)
        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.collectionView(self.collectionView!, didSelectItemAt: indexPath)
    }
    
}

extension SLLiveTextViewController : HITabBarDelegate {
    func hiTabBar(_ tabBar: HITabBar, didSelecteIndex: Int) {
        if didSelecteIndex == 1 {
            self.navigationItem.leftBarButtonItem = self.browseBarButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
}

extension SLLiveTextViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let word = recognizgedWords[indexPath.item]
        if let string = word.string {
            
            SLSignStoreManager.shared.fetchSign(word: word.string!) {
                result, error in
                
                guard let result = result else {
                    return
                }
                
                for (key, sign) in result {
                    DispatchQueue.main.async {
                        let frames = sign.frames
                        self.player.play(frames: frames)
                        self.playButton?.isEnabled = true
                    }
                    break;
                }
                
            }
            
//            if let sign = SLRecordingManager.shared.load(name: string) {
//                let frames = sign.frames
//                self.player.play(frames: frames)
//                self.playButton?.isEnabled = true
//                return
//            }
        }
        self.playButton?.isEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recognizgedWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtractTextCell", for: indexPath)
        if let eCell = cell as? ExtractedWordCell {
            eCell.numberLabel?.text = "\(indexPath.item + 1)"
            let word = recognizgedWords[indexPath.item]
            eCell.label?.text = word.string
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int.random(in: 50...140)
        return CGSize(width: Double(width), height: 44)
    }
    
    func playerDidEndPlayback(_ player: SLPlayer) {
        
    }
    
    func player(_ player: SLPlayer, didOutputFrame frame: SLFrame) {
        let image = UIImage(named: "base")
        if let outputImage = image?.cgImage?.render(for: frame) {
            self.slImageView?.image = outputImage
        }
    }
    
    func player(_ player: SLPlayer, startPlaying word: String, at index: Int) {
        
    }
}
