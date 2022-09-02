//
//  ShareViewController.swift
//  Photo
//
//  Created by SAME Team on 4/7/2022.
//

import UIKit
import Social
import MobileCoreServices
import Speech
import DSWaveformImage
import Vision
import VisionKit
import NaturalLanguage

class ShareViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SLPlayerDelegate  {

    var player = SLPlayer()
    
    @IBOutlet var waveformImageContainer : UIView!
    
    @IBOutlet var previewImageView : UIImageView!
    @IBOutlet var slImageView : UIImageView!
    
    @IBOutlet var playButton : [UIButton]!
    @IBOutlet var videoProgressSlider : [UISlider]?

    @IBOutlet var label : UILabel?
    
    @IBOutlet var collectionView : UICollectionView?
    
    @IBOutlet var mediaImageView : UIImageView?
    @IBOutlet var mediaTypeLabel : UILabel?
    
    @IBOutlet var playerVideo : PlayerView!
    
    var sentences = [NLPSentence]()
    var signDict = [String : SLSign]()
    
    var tapRegions = [CGRect]()
    var requests = [VNRequest]()
    
    @IBOutlet var audioView : UIView?
    @IBOutlet var videoView : UIView?
    @IBOutlet var imageView : UIImageView!
    
    var duration = -1.0
    
    var selectedSection = -1
    
    @IBOutlet var statusLabel : UILabel?
    
    
    var recognitionMode : Int = 0 {
        didSet {
            DispatchQueue.main.async {
                if self.recognitionMode == 0 {
                    //audio
                    self.audioView?.isHidden = false
                    self.videoView?.isHidden = true
                    self.mediaImageView?.image = UIImage(systemName: "music.note")
                    self.mediaTypeLabel?.text = "Audio"
                } else if self.recognitionMode == 1 {
                    //movie
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = false
                    self.mediaImageView?.image = UIImage(systemName: "film")
                    self.mediaTypeLabel?.text = "Movie"
                } else {
                    //image
                    self.audioView?.isHidden = true
                    self.videoView?.isHidden = true
                    self.mediaImageView?.image = UIImage(systemName: "photo")
                    self.mediaTypeLabel?.text = "Image"
                }
            }
            
        }
    }
    
    var tokenizer = NLTokenizer(unit: .word)
    
    
    var recognizgedWords = [RecognizedWord]() {
        didSet{
            //TODO
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
    
    @IBAction func dismissClicked() {
        self.extensionContext?.completeRequest(returningItems: nil)
    }
    
    let reflabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* This could've been done from the Object Library but for some reason
         the blurred view kept being deallocated. Doing it programmatically
         resulted in the same behaviour, but after a couple retries it seems
         that it is ok. Weird.
         */
        // https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view/25706250
        // only apply the blur if the user hasn't disabled transparency effects
        if UIAccessibility.isReduceTransparencyEnabled == false {
            view.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607844949, blue: 0.9607844949, alpha: 1)
            
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607844949, blue: 0.9607844949, alpha: 1)
                //.white
        }
        if let label = self.label {
            self.view.bringSubviewToFront(label)
        }
        
        self.player.delegate = self
        
        self.processResource()
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
    
    func processResource() {
        
        // Do any additional setup after loading the view.
        print("yoyo: \(self.extensionContext?.inputItems)")
        
        if let inputItems = self.extensionContext?.inputItems {
            for inputItem in inputItems {
                if let extensionItem = inputItem as?  NSExtensionItem  {
                    if let itemProviders = extensionItem.attachments as? [NSItemProvider] {
                        for itemProvider in itemProviders {
                            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeMPEG4Audio as String) {
                                itemProvider.loadItem(forTypeIdentifier: kUTTypeMPEG4Audio as String, completionHandler: {
                                    audioProvider, error in
                                    if let url = audioProvider as? URL {
                                        print("this is url")
                                        self.recognitionMode = 0
                                        self.processForAudio(url: url)
                                    }
                                })
                            } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeMovie as String) {
                                itemProvider.loadItem(forTypeIdentifier: kUTTypeMovie as String, completionHandler: {
                                    audioProvider, error in
                                    if let url = audioProvider as? URL {
                                        print("this is url for movie")
                                        //self.processForAudio(url: url)
                                        self.recognitionMode = 1
                                        self.processForVideo(url: url)
                                    }
                                })
                            } else if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                                itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, completionHandler: {
                                    audioProvider, error in
                                    if let url = audioProvider as? URL {
                                        print("this is url for image")
                                        self.recognitionMode = 2
                                        self.processForImage(url: url)
                                    }
                                })
                            }
                        }
                    }
                }
            }
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
    
    
}

extension ShareViewController {
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


extension ShareViewController {

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
    }
}



//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
