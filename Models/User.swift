//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by 吉田　知代 on 2020/12/30.
//  Copyright © 2020 吉田　知代. All rights reserved.
//

import Foundation
import Firebase

class User {
    
 
    let createdAt: Timestamp
    var uid: String?
    let usename: String?
    let blockId :String?
    
    init(dic: [String: Any]) {
        self.usename = dic["usename"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
        self.blockId = dic["blockId"] as? String ?? ""



    }
    
}

