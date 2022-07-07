//
//  PreviewViewController.swift
//  HearInclusive
//
//  Created by SAME Team on 15/6/2022.
//

import UIKit
import AVFoundation
class PreviewViewController: UIViewController {

    var url : URL?
    
    @IBOutlet var videoView : UIView!
    @IBOutlet var label : UILabel!
    
    var playerLayer: AVPlayerLayer?
    var currentPlayer : AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = url else {
            return
        }
        self.label.text = url.lastPathComponent.replacingOccurrences(of: ".mp4", with: "")
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if let videoURL: URL = url {
            let player = AVPlayer(url: videoURL)
            self.currentPlayer = player
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer!.frame = self.videoView!.bounds
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.videoView.layer.addSublayer(self.playerLayer!)
            self.playerLayer?.player?.play()
        }
 
        
    }
    
    @IBAction func replay(){
        self.currentPlayer?.seek(to: .zero)
        self.currentPlayer?.play()
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
