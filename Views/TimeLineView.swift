//
//  TimeLineDelegate.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/03/09.
//  Copyright © 2021 吉田　知代. All rights reserved.
//


import UIKit

protocol TimeLineViewDelegate: class{
    func tappedSendButton(text: String)
}

class TimeLineView: UIView{
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
        print("tapped SendButton")
    }
    
    weak var delegate: TimeLineViewDelegate?
    
    
}




