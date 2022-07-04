//
//  UIViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import PhotosUI
class ViewControlelr : UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            print("ok")
        }
    }
}
