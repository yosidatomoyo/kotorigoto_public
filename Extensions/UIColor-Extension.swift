//
//  UIColor-Extension.swift
//  ChatAppWithFirebase
//
//  Created by 吉田　知代 on 2020/08/13.
//  Copyright © 2020 吉田　知代. All rights reserved.
//

import UIKit

extension UIColor{
    
    static func rgb(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor{
        return self.init(red : red / 255, green : green / 255, blue : blue / 255,alpha:1)
    }
}
