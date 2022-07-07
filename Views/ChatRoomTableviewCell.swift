//
//  ChatRoomTableviewCell.swift
//  ChatAppWithFirebase
//
//  Created by 吉田　知代 on 2020/08/13.
//  Copyright © 2020 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell{
    
    var message: Message? {
        didSet{
            
            
            if let message = message {
            partnermessageTextView.text = message.message
    
               let width = estimateFrameForTextView(text: message.message).width + 20
               messageTextViewWidthConstraint.constant = width
                partnerdateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                
                myMessageTextView.text = message.message
                let witdh = estimateFrameForTextView(text: message.message).width + 20
             
             myMessageTextViewWithConstraint.constant = witdh
             myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                
                
                
            }
        }
        
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnermessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var partnerdateLabel: UILabel!
   
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var myMessageTextViewWithConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        partnermessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           checkWhichUserMessage()
       }
    
    private func checkWhichUserMessage() {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           
           if uid == message?.uid {
            partnermessageTextView.isHidden = true
            partnerdateLabel.isHidden = true
               userImageView.isHidden = true
               
               myMessageTextView.isHidden = false
               myDateLabel.isHidden = false
               
               if let message = message {
                   myMessageTextView.text = message.message
                   let witdh = estimateFrameForTextView(text: message.message).width + 20
                
                myMessageTextViewWithConstraint.constant = witdh
                   
                   myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
               }
           } else {
            partnermessageTextView.isHidden = false
            partnerdateLabel.isHidden = false
                       userImageView.isHidden = false
                       
                       myMessageTextView.isHidden = true
                       myDateLabel.isHidden = true
                           
                       }
                       
                       if let message = message {
                        partnermessageTextView.text = message.message
                           let witdh = estimateFrameForTextView(text: message.message).width + 20 //キーボードからの高さ
                           messageTextViewWidthConstraint.constant = witdh
                           
                        partnerdateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                       }
                   }
                   
               }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
           let size = CGSize(width: 200, height: 1000)
           let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
           
           return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
       }
       
       private func dateFormatterForDateLabel(date: Date) -> String {
           let formatter = DateFormatter()
           formatter.timeStyle = .short
           formatter.timeStyle = .short
           formatter.locale = Locale(identifier: "ja_JP")
           return formatter.string(from: date)
       }
       
   
