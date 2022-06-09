//
//  Post.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/03/28.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    let postId: String
    let memeber: [String]
    let createdAt: Timestamp
    let message: String
    let uid: String
    
    var documentId: String?

    init(dic: [String: Any]) {
        self.postId = dic["postId"] as? String ?? ""
        self.memeber = dic["memeber"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
 
    }
    
}

