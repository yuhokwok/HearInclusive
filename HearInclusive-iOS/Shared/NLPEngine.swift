//
//  NLPEngine.swift
//  HearInclusive
//
//  Created by SAME Team on 30/8/2022.
//

import Foundation
import NaturalLanguage
import UIKit

struct NLPSentence {
    var words : [NLPWord] = []
}

struct NLPWord{
    var text : String
    var tag : NLTag
}

struct NLPEngine {

    
    
    var words : [String] = []
    var tokenizer = NLTokenizer(unit: .word)
    let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
                                
    static var shared = NLPEngine()
    
    
    mutating func processForImage(_ inputString : String) -> NLPSentence {
        let text = inputString
        
        
        //self.tokenizer.string = text
        self.tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        
        let schemes = NLTagger.availableTagSchemes(for: .word, language: .traditionalChinese)
        
        tagger.setLanguage(.traditionalChinese, range: range)
        let tags = tagger.tags(in: range, unit: .word, scheme: .nameTypeOrLexicalClass)
        
        let sentence = self.packForImage(tags: tags, text : text)
        

        return sentence
    }
    
    
    mutating func process(_ inputString : String) -> [NLPSentence] {
        let text = inputString
        
        
        //self.tokenizer.string = text
        self.tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        
        let schemes = NLTagger.availableTagSchemes(for: .word, language: .traditionalChinese)
        for scheme in schemes {
            print("\(scheme.rawValue)")
        }
        
//        print("available tag scheme: \(NLTagger.availableTagSchemes(for: .word, language: .traditionalChinese))")
//
        tagger.setLanguage(.traditionalChinese, range: range)
        let tags = tagger.tags(in: range, unit: .word, scheme: .nameTypeOrLexicalClass)
        
        let sentences = self.pack(tags: tags, text : text)
        
        //print(sentences)
        
        
//        tagger.enumerateTags(in: range, unit: .word, scheme: .nameTypeOrLexicalClass) {
//            tag, range in
//
//            if let tag = tag {
//                let substring = text[range]
//                print("\(substring): \(tag)")
//            }
//
//            return true
//        }
        
        
        
        
        //self.words.removeAll()
//        self.tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) {
//            range, attributes in
//            //print(string[range])
//
//            let substring = text[range]
//
//            print("\(substring) - \(attributes)")
//
//            self.words.append("\(substring)")
//            return true
//        }
        
        
       // self.performSegue(withIdentifier: "RecordHandSign", sender: nil)
    
        return sentences
    }
    
    func packForImage( tags : [(NLTag?, Range<String.Index>)], text : String) -> NLPSentence {
        var sentence = NLPSentence()
        for tag in tags {
            let t = tag.0
            let r = tag.1
            let subString = text[r]
            
            if let t = t {
                if t != .punctuation && t != .otherPunctuation {
                    let word = NLPWord(text: "\(subString)", tag: t)
                    sentence.words.append(word)
                }
            }
        }
        return sentence
    }
    
    func pack( tags : [(NLTag?, Range<String.Index>)], text : String) -> [NLPSentence] {
        var sentences = [NLPSentence]()
        
        var sentence = NLPSentence()
        for tag in tags {
            let t = tag.0
            let r = tag.1
            let subString = text[r]
            
            if let t = t {
                if t == .punctuation || t == .otherPunctuation {
                    if sentence.words.count > 0 {
                        sentences.append(sentence)
                        sentence = NLPSentence()
                    }
                } else {
                    let word = NLPWord(text: "\(subString)", tag: t)
                    sentence.words.append(word)
                }
            }
        }
        
        if sentence.words.count > 0 {
            sentences.append(sentence)
            sentence = NLPSentence()
        }
        return sentences
    }
    
    
}


extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
