//
//  TabColor.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/02/28.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit

class MyTabBar: UITabBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 58
        return size
    }

}
