//
//  TimeLine.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/03/07.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import Foundation
import Firebase

class TimeLine {
    
    let postId: String
    let memebers: [String]
    let createdAt: Timestamp
    let message: String
    
    var uid : String?
    var documentId: String?
    var ThreadRoomId : String?
    var MessageId : String?
    var blockedId : String?
    var genle : String?
    
    
    init(dic: [String: Any]) {
        self.postId = dic["postId"] as? String ?? ""
        self.memebers = dic["memeber"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
        self.ThreadRoomId = dic["ThreadRoomId"] as? String ?? ""
        self.MessageId = dic["MessageId"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.blockedId = dic["blockedId"] as? String ?? ""
        self.genle = dic["genle"] as? String ?? ""


    }
    
}


