//
//  PreviewViewController.swift
//  HearInclusive
//
//  Created by Yu Ho Kwok on 15/6/2022.
//

import UIKit
import AVFoundation
class SLPreviewViewController: UIViewController , SLPlayerDelegate {

    var url : URL?
    
    @IBOutlet var videoView : UIImageView!
    @IBOutlet var label : UILabel!
    
    var currentPlayer : SLPlayer?
    
    var frames : [SLFrame] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url else {
            return
        }
        
        self.currentPlayer = SLPlayer()
        self.currentPlayer?.delegate = self
        self.label.text = url.lastPathComponent.replacingOccurrences(of: ".slframes", with: "")
        let word = url.lastPathComponent.replacingOccurrences(of: ".slframes", with: "")
        if let frames  = SLRecordingManager.shared.load(name: word) {
            self.frames = frames
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        currentPlayer?.play(frames: self.frames)
 
        
    }
    
    
    func playerDidEndPlayback(_ player: SLPlayer) {
        
    }
    
    func player(_ player: SLPlayer, didOutputFrame frame: SLFrame) {
        print("output")
        let image = UIImage(named: "base")
        if let outputImage = image?.cgImage?.render(for: frame) {
            self.videoView.image = outputImage
        }
    }
    
    
    @IBAction func replay(){
        self.currentPlayer?.stop()
        self.currentPlayer?.play(frames: self.frames)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
