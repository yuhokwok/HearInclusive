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
import DSWaveformImage
import MobileCoreServices
import UniformTypeIdentifiers

class SLLiveTextViewController : UIViewController, SLPlayerDelegate, HITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    
    var player = SLPlayer()
    
    //wave form
    @IBOutlet var waveformImageContainer : UIView!
    
    @IBOutlet var liveTextButton : UIButton?
    
    //audio / video playback
    @IBOutlet var playButton : [UIButton]!
    @IBOutlet var videoProgressSlider : [UISlider]?
    
    @IBOutlet var playerVideo : PlayerView!
    @IBOutlet var label : UILabel?
    
    
    //status
    @IBOutlet var statusLabel : UILabel?
    
    @IBOutlet var hiTabBar : HITabBar?
    @IBOutlet var browseBarButtonItem : UIBarButtonItem?
    
    
    
    private let videoCapture = VideoCapture()
    private var currentImage: UIImage?
    
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var slImageView : UIImageView!
    
    @IBOutlet var languageButton : MenuButton?
    @IBOutlet var subLanguageButton : MenuButton?
    
    //data model
    var sentences = [NLPSentence]()
    var signDict = [String : SLSign]()
    
    var tapRegions = [CGRect]()
    var requests = [VNRequest]()
    
    var duration = -1.0
    var selectedSection = -1
    
    var tokenizer = NLTokenizer(unit: .word)
    
    let reflabel = UILabel()
    
    @IBOutlet var videoView : UIView?
    @IBOutlet var audioView : UIView?
    @IBOutlet var hintView : UIView?
    
    var mediaRecognitionMode : Int = -1 {
        didSet {
            DispatchQueue.main.async {
                if self.mediaRecognitionMode == 0 {
                    //audio
                    self.audioView?.isHidden = false
                    self.videoView?.isHidden = true
                    self.hintView?.isHidden = true

                } else if self.mediaRecognitionMode == 1 {
                    //movie
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = false
                    self.hintView?.isHidden = true

                } else if self.mediaRecognitionMode == 2 {
                    //image
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = true
                    self.hintView?.isHidden = true
                } else {
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = true
                    self.hintView?.isHidden = false
                }
            }
            
        }
    }
    
    func hiTabBar(_ tabBar: HITabBar, didSelecteIndex: Int, from oldIndex: Int) {
        if didSelecteIndex == 2 {
            self.hiTabBar?.selectedIndex = oldIndex
            self.performSegue(withIdentifier: "showSetting", sender: nil)
        } else if didSelecteIndex == 1 {
            
            videoCapture.stopCapturing()
            
            for subviews in self.imageView.subviews {
                subviews.removeFromSuperview()
            }
            self.slImageView.image = nil
            self.statusLabel?.text = "Preview"
            self.sentences.removeAll()
            self.collectionView?.reloadData()
            
            self.mediaRecognitionMode = -1
            self.navigationItem.leftBarButtonItem = self.browseBarButtonItem
            
            self.liveTextButton?.isHidden = true
            self.player.stop()
            self.playerVideo.stop()
            
        } else if didSelecteIndex == 0 {
            self.player.stop()
            videoCapture.startCapturing() {
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = nil
            
                    for subviews in self.imageView.subviews {
                        subviews.removeFromSuperview()
                    }
                    self.slImageView.image = nil
                    self.statusLabel?.text = "Preview"
                    self.sentences.removeAll()
                    self.collectionView?.reloadData()
                    
                    self.liveTextButton?.isHidden = false
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = true
                    self.hintView?.isHidden = true
                }
            }

        }
    }

    @IBAction func backfromSetting(){
        
    }
    
    @IBOutlet var collectionView : UICollectionView?
    var recognizgedWords = [RecognizedWord]() {
        didSet{
            //TODO
//            var recognizedWords = [RecognizedWord]()
//            for recognizgedWord in recognizgedWords {
//                self.tokenizer.string = recognizgedWord.string!
//                var words : [String] = []
//                self.tokenizer.enumerateTokens(in: recognizgedWord.string!.startIndex..<recognizgedWord.string!.endIndex) {
//                    range, attributes in
//                    let substring = recognizgedWord.string![range]
//                    words.append("\(substring)")
//                    return true
//                }
//                for word in words {
//
//                    recognizedWords.append(RecognizedWord(string: word, boundingBox: recognizgedWord.boundingBox))
//                }
//            }
//            recognizgedWords = recognizedWords
            
            self.tapRegions.removeAll()
            self.sentences.removeAll()
            for recognizedWord in recognizgedWords {
                let sentence = NLPEngine.shared.processForImage(recognizedWord.string!)
                self.sentences.append(sentence)
                //tapRegions.append(recognizedWord.boundingBox)
            }
            
            self.collectionView?.reloadData()
            self.fetchSignForSentences()
        }
    }
    
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
    
    func fetchSignForSentences(){
        self.statusLabel?.text = "Preparing..."
        var words = [String]()
        for sentence in self.sentences {
            for word in sentence.words {
                words.append(word.text)
            }
        }
        
        SLSignStoreManager.shared.fetchSigns(words: words, completion: {
            fetchReuslt, fetchError in
            
            if let fetchReuslt = fetchReuslt {
                var signDict = [String : SLSign]()
                for ( _ , sign ) in fetchReuslt {
                    signDict[sign.name] = sign
                }
                self.signDict = signDict
                DispatchQueue.main.async {
                    self.statusLabel?.text = "Ready"
                }
            }
        })
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
            player.stop()
            
            isLive = false
            for subviews in self.imageView.subviews {
                subviews.removeFromSuperview()
            }
            
            sentences.removeAll()
            self.collectionView?.reloadData()
        }
    }
    
    
    
    @IBAction func playForAll(){
        print("play all sentences")
        
        if self.player.isPlayering == true {
            playerVideo.pause()
            
            for button in playButton {
                button.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            //pause
            DispatchQueue.main.async {
                self.player.pause()
            }
        } else if self.player.isPause == true {
            playerVideo.play()
            
            for button in playButton {
                button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            
            DispatchQueue.main.async {
                self.player.play()
            }
        } else {
            
            for button in playButton {
                button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            
            //play
            
            try? playerVideo.player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            playerVideo.play()
            
            self.selectedSection = -1
            DispatchQueue.main.async {
                self.player.play(scentences: self.sentences, signDict: self.signDict)
            }
        }
        
        
    }

    
    @IBAction func playVideoClicked(){
        
        self.playForAll()
    }


    @IBAction func playBtnClicked(){
        self.player.play()
    }
    

    @IBAction func browse() {
        
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
        
//        let actionSheet = UIAlertController(title: "Select Media Source", message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) {
//            action in
//
//            let picker = UIImagePickerController()
//            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
//            picker.sourceType = .photoLibrary
//            picker.allowsEditing = true
//            picker.delegate = self
//            self.present(picker, animated: true)
//        })
//
//        actionSheet.addAction(UIAlertAction(title: "File", style: .default) {
//            action in
//
//            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image, UTType.movie, UTType.audio])
//            picker.delegate = self
//            picker.allowsMultipleSelection = false
//            self.present(picker, animated: true)
//        })
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
//            action in
//        })
//        self.present(actionSheet, animated: true)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        
        let url = urls[0]
        
        let pathExtension = url.pathExtension
        
        switch(pathExtension){
        case "jpg", "jpeg", "png", "gif":

            print("Image file")
            
        case "mp4", "m4v", "mov":
            print("Video file")
            
            processForVideo(url: url)
        case "m4a", "wav", "aac", "mp3":
            print("Audio file")
            
            processForAudio(url: url)
        default:
            print("Something else!")
        }
        
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        for subviews in self.imageView.subviews {
            subviews.removeFromSuperview()
        }
        
        self.slImageView.image = nil
        self.statusLabel?.text = "Preview"
        self.sentences.removeAll()
        self.collectionView?.reloadData()
        
        if let imageUrl = info[.imageURL] as? URL {
            print("\(imageUrl)")
            self.mediaRecognitionMode = 2
            //self.processForVideo(url: movieUrl)
            //print("\(movieUrl)")
            self.processForImage(url: imageUrl)
        } else if let movieUrl = info[.mediaURL] as? URL {
            self.mediaRecognitionMode = 1
            self.processForVideo(url: movieUrl)
            print("\(movieUrl)")
        }
        
        
    }
}


extension SLLiveTextViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sentences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sentences[section].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtractTextCell", for: indexPath)
        if let eCell = cell as? ExtractedWordCell {
            eCell.numberLabel?.text = "\(indexPath.item + 1)"
            //let word = recognizgedWords[indexPath.item]
            let word = sentences[indexPath.section].words[indexPath.item]
            eCell.label?.text = word.text
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = reflabel.font!
        let word = sentences[indexPath.section].words[indexPath.item]
        let width = word.text.widthOfString(usingFont: font)
        return CGSize(width: width + 44 + 10, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                   withReuseIdentifier: "ExtractTextSeperator", for: indexPath)
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return .zero
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 15)
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let word = sentences[indexPath.section].words[indexPath.row]
        
        let string = word.text
            
        if let frames = self.signDict[string]?.frames {
            self.selectedSection = -1
            self.player.play(frames: frames)
            
            for button in self.playButton {
                button.isEnabled = true
            }
        }
//        let word = recognizgedWords[indexPath.item]
//        if let string = word.string {
//
//            SLSignStoreManager.shared.fetchSign(word: word.string!) {
//                result, error in
//
//                guard let result = result else {
//                    return
//                }
//
//                for (key, sign) in result {
//                    DispatchQueue.main.async {
//                        let frames = sign.frames
//                        self.player.play(frames: frames)
//                        self.playButton?.isEnabled = true
//                    }
//                    break;
//                }
//
//            }
//
////            if let sign = SLRecordingManager.shared.load(name: string) {
////                let frames = sign.frames
////                self.player.play(frames: frames)
////                self.playButton?.isEnabled = true
////                return
////            }
//        }
//        self.playButton?.isEnabled = false
    }
    
    
    func playerDidEndPlayback(_ player: SLPlayer) {
        for button in self.playButton {
            button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func player(_ player: SLPlayer, didOutputFrame frame: SLFrame) {
        let image = UIImage(named: "base")
        if let outputImage = image?.cgImage?.render(for: frame) {
            self.slImageView?.image = outputImage
        }
    }
    
    func player(_ player: SLPlayer, startPlaying word: String, at index: Int) {
        if selectedSection != -1 {
            self.collectionView?.selectItem(at: IndexPath(item: index, section: selectedSection), animated: true, scrollPosition: .top)
            return
        }
        
        let index = index
        print("play index: \(index)")
        var targetIndex = 0
        for i in 0..<sentences.count {
            for j in 0..<sentences[i].words.count {
                if targetIndex == index {
                    let indexPath = IndexPath(row: j, section: i)
                    self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .top)
                    print("targetIndex: \(targetIndex)")
                }
                targetIndex += 1
            }
        }
    }
}


extension [UIButton] {
    var isEnabled : Bool {
        set {
            for element in self {
                element.isEnabled = newValue
            }
        }
        
        get {
            return false
        }
    }
}
