//
//  ShareViewController.swift
//  Photo
//
//  Created by Yu Ho Kwok on 4/7/2022.
//

import UIKit
import Social

class ShareViewController: UIViewController {
    
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
               view.backgroundColor = .white

            let blurEffect = UIBlurEffect(style: .light)
               let blurEffectView = UIVisualEffectView(effect: blurEffect)
               //always fill the view
               blurEffectView.frame = self.view.bounds
               blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

               view.insertSubview(blurEffectView, at: 0)
           } else {
               view.backgroundColor = .white
           }
           // Do any additional setup after loading the view.
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

}


//class ShareViewController: SLComposeServiceViewController {
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
//
//}
