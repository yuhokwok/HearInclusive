/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helper class for listing, deleting, and viewing app document directory "capture" folders.
*/

import Combine
import Foundation

import os

class CaptureFolderManager {
    static private let workQueue = DispatchQueue(label: "CaptureFolderManager.Work", qos: .userInitiated)
    
    var captureDir: URL? = nil
    init(url captureDir: URL) {
        self.captureDir = captureDir
    }
    
    static func requestFramesFolderListing(completion : @escaping ([URL])->Void){
        workQueue.async {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var documentsDirectory = paths[0]
            documentsDirectory.appendPathComponent("slsigns/")
            
            guard let docFolder = documentsDirectory else {
                completion([])
                return
            }
            
//            if FileManager.default.fileExists(atPath: documentsDirectory.absoluteString.replacingOccurrences(of: "file:///", with: "/")) == false {
//                print("create folder")
//                try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
//            }
            
            guard let folderListing =
                    try? FileManager.default.contentsOfDirectory(at: docFolder,
                                                                 includingPropertiesForKeys: [.creationDateKey],
                                                                 options: [ .skipsHiddenFiles ]) else {
                completion([])
                return
            }
            
            // Sort by creation date, newest first.
            let sortedFolderListing = folderListing
                .sorted { lhs, rhs in
                    creationDate(for: lhs) > creationDate(for: rhs)
                }
            completion(sortedFolderListing)
        }
        
    }
    
    static func requestCaptureFolderListing(completion : @escaping ([URL])->Void){
        workQueue.async {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var documentsDirectory = paths[0]
            documentsDirectory.appendPathComponent("signs/")
            
            guard let docFolder = documentsDirectory else {
                completion([])
                return
            }
            
            guard let folderListing =
                    try? FileManager.default.contentsOfDirectory(at: docFolder,
                                                                 includingPropertiesForKeys: [.creationDateKey],
                                                                 options: [ .skipsHiddenFiles ]) else {
                completion([])
                return
            }
            
            // Sort by creation date, newest first.
            let sortedFolderListing = folderListing
                .sorted { lhs, rhs in
                    creationDate(for: lhs) > creationDate(for: rhs)
                }
            completion(sortedFolderListing)
        }
        
    }
    
    private static func creationDate(for url: URL) -> Date {
        let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        
        if date == nil {
            logger.error("creation data is nil for: \(url.path).")
            return Date.distantPast
        } else {
            return date!
        }
    }

}

private let logger = Logger(subsystem: "com.apple.sample.CaptureSample",
                            category: "CaptureFolderState")

/// This helper class loads the contents of an image capture folder. It uses asynchronous calls that run on a
/// background queue and includes static methods for retrieving the top-level capture folder, which contains
/// separate subfolders for each capture. Use a different instance of this class for each capture folder.
class CaptureFolderState: ObservableObject {
    static private let workQueue = DispatchQueue(label: "CaptureFolderState.Work",
                                                 qos: .userInitiated)


    /// This method returns a `Future` instance that's populated with a list of capture folders sorted by creation date.
    static func requestCaptureFolderListing() -> Future<[URL], Never> {
        let future = Future<[URL], Never> { promise in
            workQueue.async {
                
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                var documentsDirectory = paths[0]
                documentsDirectory.appendPathComponent("signs/")
                
                guard let docFolder = documentsDirectory else {
                    promise(.success([]))
                    return
                }
                guard let folderListing =
                        try? FileManager.default
                        .contentsOfDirectory(at: docFolder,
                                             includingPropertiesForKeys: [.creationDateKey],
                                             options: [ .skipsHiddenFiles ]) else {
                    promise(.success([]))
                    return
                }
                // Sort by creation date, newest first.
                let sortedFolderListing = folderListing
                    .sorted { lhs, rhs in
                        creationDate(for: lhs) > creationDate(for: rhs)
                    }
                promise(.success(sortedFolderListing))
            }
        }
        return future
    }
    
    private static func creationDate(for url: URL) -> Date {
        let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        
        if date == nil {
            logger.error("creation data is nil for: \(url.path).")
            return Date.distantPast
        } else {
            return date!
        }
    }

}
