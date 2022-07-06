//
//  AppDelegate.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by Mable Hin on 14/11/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("slframes")
        
        print("\(documentsDirectory.absoluteString)")
        let path = documentsDirectory.absoluteString.replacingOccurrences(of: "file:///", with: "/", options: .literal, range: nil)
        if FileManager.default.fileExists(atPath: path, isDirectory: nil) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                print("create folder")
            } catch {
                print("fail to create folder")
            }
        } else {
            print("use existing folder")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

