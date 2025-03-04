//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/04/28.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
