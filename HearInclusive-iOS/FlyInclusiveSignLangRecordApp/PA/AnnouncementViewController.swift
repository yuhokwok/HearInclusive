//
//  AnnouncementViewController.swift
//  FlyInclusiveSignLangRecordApp
//
//  Created by FlyInclusive on 19/11/2021.
//

import UIKit
import NaturalLanguage

class AnnoucementViewController : UIViewController, SpeechManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    
    var tokenizer = NLTokenizer(unit: .word)
    
    var words = [String]()
    
    var speechManager = SpeechManager()
    
    @IBOutlet var label : UILabel!
    
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechManager.delegate = self
        
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
    }
    
    @IBAction func touchDown(){
        self.speechManager.startRecording()
        print("start")
    }
    
    @IBAction func touchUp(){
        self.speechManager.stopRecording()
        print("stop")
        
        let string = self.label.text!
        tokenizer.string = self.label.text!
        words.removeAll()
        tokenizer.enumerateTokens(in: self.label.text!.startIndex..<self.label.text!.endIndex) {
            range, attributes in
            //print(string[range])
            let substring = string[range]
            self.words.append("\(substring)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return true
        }
        
    }

}

extension AnnoucementViewController {
    func speech(_ manage: SpeechManager, result: String) {
        print("\(result)")
        self.label.text = "\(result)"
        
    }
}

extension AnnoucementViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            words.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        cell.textLabel?.text = words[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        return [ dragItem ]
    }
        
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //move row actions
        
        let word = self.words.remove(at: sourceIndexPath.row)
        self.words.insert(word, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        print("drag session did end")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PAViewController {
            destination.text = self.label.text!
            destination.words = self.words
        }
    }
}
