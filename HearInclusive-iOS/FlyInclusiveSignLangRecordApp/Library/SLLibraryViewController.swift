//
//  SLLibraryViewController.swift
//  HearInclusive
//
//  Created by SAME Team on 6/7/2022.
//

import UIKit
import AVFoundation
import NaturalLanguage
import CloudKit

class SLLibraryViewController : UITableViewController {
    
    var urls : [URL] = []
    
    var signs : [CKRecord.ID : SLSign] = [:]
    
    var words : [String] = []
    
    var alertTextField : UITextField?
    
    var tokenizer = NLTokenizer(unit: .word)
    
    @IBAction func backFromRecorder(segue : UIStoryboardSegue){
        if segue.source is SLRecordingViewController {
            
            
            let manager = SLRecordingManager.shared
            manager.save(storeCompletitonHandler: {
                records in
                
                print("run handler")
                //to do insert tableview,
                
                //backup, refresh all result
                print("re-fetch")
                
                //SLSignStoreManager.shared.fetchSigns(completion: {
                SLSignStoreManager.shared.fetchSignsPartial(completion: {
                    signs, error in

                    print("\(error)")
                    
                    if let signs = signs {
                        print("reload table")
                        DispatchQueue.main.async {
                            self.signs = signs
                            self.tableView.reloadData()
                        }
                    }
                })
                

            })
            
            

            
//            CaptureFolderManager.requestFramesFolderListing(completion: {
//                urls in
//                DispatchQueue.main.async {
//
//                    self.urls = urls
//                    self.tableView.reloadData()
//
//                }
//            })
        }
    }
    
    @IBAction func addHandSign(){
        let alert = UIAlertController(title: "Add Hand Sign", message: nil, preferredStyle: .alert)
        
        alert.addTextField(){
            textfield in
            textfield.placeholder = "Word or Phrase You want to add"
            self.alertTextField = textfield
        }
        
        alert.addAction(UIAlertAction(title: "Analysis", style: .default) {
            action in
            
            if let textField = self.alertTextField {
                if let text = textField.text {
                    
                    self.tokenizer.string = text
                    self.words.removeAll()
                    self.tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) {
                        range, attributes in
                        //print(string[range])
                        let substring = text[range]
                        self.words.append("\(substring)")
                        return true
                    }
                    
                    self.performSegue(withIdentifier: "RecordHandSign", sender: nil)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Record", style: .default) {
            action in
            
            if let textField = self.alertTextField {
                if let text = textField.text {
                    
                    self.words.removeAll()
                    self.words.append(text)
                    self.performSegue(withIdentifier: "RecordHandSign", sender: nil)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        CaptureFolderManager.requestFramesFolderListing(completion: {
//            urls in
//            DispatchQueue.main.async {
//
//                self.urls = urls
//                self.tableView.reloadData()
//
//            }
//        })
        
        SLSignStoreManager.shared.fetchSignsPartial(completion: {
            signs, error in

            if let signs = signs {
                DispatchQueue.main.async {
                    self.signs = signs
                    self.tableView.reloadData()
                }
            }
        })
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let url = urls[indexPath.row]
            
            let key = Array(self.signs.keys)[indexPath.item]
            
            SLSignStoreManager.shared.deleteSign(recordId: key, completion: {
                error in
                
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.signs.removeValue(forKey: key)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            })
            
            
            /*
            try? FileManager.default.removeItem(at: url)
            urls.remove(at: indexPath.row)
             */
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return urls.count
        return signs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewViewCell", for: indexPath)

        if let pCell = cell as? PreviewViewCell {
            
            let recordId = Array(signs.keys)[indexPath.row]
            
            if let sign = signs[recordId] {
                
                pCell.label.text = sign.name
                
                let image = UIImage(named: "base")
                if let frame = sign.previewFrame {
                    if let outputImage = image?.cgImage?.render(for: frame) {
                        pCell.tbView.image = outputImage
                    }
                }
            }
            
            /*
            pCell.label.text = urls[indexPath.row].lastPathComponent.replacingOccurrences(of: ".slsigns", with: "")
             
            let name = urls[indexPath.row].lastPathComponent.replacingOccurrences(of: ".slsigns", with: "")
            if let sign = SLRecordingManager.shared.load(name: name) {
                let frames = sign.frames
                let count = frames.count / 2
                if count < frames.count {
                    let frame = frames[count]
                    let image = UIImage(named: "base")
                    if let outputImage = image?.cgImage?.render(for: frame) {
                        pCell.tbView.image = outputImage
                    }
                    
                }
            }
             */

        }
        


        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
     */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RecordHandSign" {
            if let recordingVC = segue.destination as? SLRecordingViewController {
                recordingVC.words = self.words
            }
        } else if let vc = segue.destination as? SLPreviewViewController {
            //vc.url = urls[self.tableView.indexPathForSelectedRow!.item]
            let recordId = Array(signs.keys)[self.tableView.indexPathForSelectedRow!.item]
            vc.sign = signs[recordId]
        }
    }
}

