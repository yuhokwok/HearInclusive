//
//  SLSignStoreManager.swift
//  HearInclusive
//
//  Created by Yu Ho Kwok on 23/7/2022.
//

import Foundation
import CloudKit

enum FetchError {
    case fetchingError, noRecords, none
}

struct SLSignStoreManager {
    static var shared = SLSignStoreManager()
    
    private let RecordType = "SLSign"
    
    func fetchSigns(completion: @escaping ([SLSign]?, FetchError) -> Void) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        let query = CKQuery(recordType: RecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        database.perform(query, inZoneWith: CKRecordZone.default().zoneID, completionHandler: {
            (records, error) -> Void in
            self.processQueryResponseWith(records: records, error: error as NSError?, completion: {
                fetchedRecords, fetchError in

                completion(fetchedRecords, fetchError)
            })
        })
    }
    
    
    private func processQueryResponseWith(records: [CKRecord]?, error: NSError?,
                                          completion: @escaping ([SLSign]?, FetchError) -> Void) {
        
        guard error == nil else {
            print("\(error?.localizedDescription)")
            completion(nil, .fetchingError)
            return
        }
        
        guard let records = records, records.count > 0 else {
            completion(nil, .noRecords)
            return
        }
        
        var signs = [SLSign]()
        for record in records {
            if let json = record["json"] as? String {
                if let data = json.data(using: .utf8), let sign = SLSign.load(jsonData: data) {
                    signs.append(sign)
                }
            }
        }
        
        completion(signs, .none)
    }
    
    func deleteSign() {
        
        
    }
    
    func storeSigns(signs : [SLSign], for collection : String = "hksl",
                    storeCompletitonHandler: (([CKRecord]) -> Void)?) {
        CKContainer.default().accountStatus { accountStatus, error in
            if accountStatus == .noAccount {
                print("sign in sin la")
            }
            else {
                // Save your record here.
                return
            }
        }
        
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        var records = [CKRecord]()
        
        for sign in signs {
            let record = CKRecord(recordType: RecordType)
            record.setValue(sign.jsonString, forKey: "json")
            record.setValue(sign.name, forKey: "name")
            record.setValue(sign.collection, forKey: "collection")
            records.append(record)
        }
        

        database.modifyRecords(saving: records, deleting: [], savePolicy: .changedKeys, atomically: true, completionHandler: {
            result in
        
            switch result {
            case .success(let saveResult, let deleteResult):
                print("\(saveResult)")
                var records = [CKRecord]()
                for (recordId, recordResult) in saveResult {
                    switch recordResult {
                    case .success(let record):
                        records.append(record)
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                }
                storeCompletitonHandler?(records)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }

        })
    }
    
    func storeSign(sign : SLSign, with name : String, for collection : String = "hksl"){
        
        CKContainer.default().accountStatus { accountStatus, error in
            if accountStatus == .noAccount {
                print("sign in jor")
            }
            else {
                // Save your record here.
                return
            }
        }
        
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        
        let record = CKRecord(recordType: RecordType)
        
        //let jsonDict = sign.dict
        guard let jsonString = sign.jsonString else {
            return
        }
        
        
        //print("\(jsonString)")
        //record.setValuesForKeys(["json" : "test"])
        print("name: \(sign.name)")
        record.setValue(sign.name, forKey: "name")
        record.setValue(jsonString, forKey: "json")
        record.setValue(sign.collection, forKey: "collection")
        
        database.save(record, completionHandler: {
            record, error in
            
            print("\(record?.recordID) saved")
            print("\(error?.localizedDescription)")
        })
        
    }
}
