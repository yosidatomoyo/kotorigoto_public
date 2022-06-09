//
//  DonU.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/05/23.
//  Copyright © 2021 吉田　知代. All rights reserved.
//


import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD
import Nuke
import SnapKit

class DoneLoginHowToUseSecond: UIViewController {
    
    @IBOutlet weak var tableViewSecond: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackgroundSeconds(name: "useFirst")

        let image = UIImage(named: "howToUseSecond.jpg")
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = image
        self.tableViewSecond.backgroundView = imageView
        
        let rigth4HomeButton = UIBarButtonItem(title: "開始する", style: .plain, target: self, action: #selector(tappedStartButton))
        navigationItem.rightBarButtonItem = rigth4HomeButton
        navigationItem.rightBarButtonItem?.tintColor = .brown
        
        let backButton = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(tappedbackButton))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = .brown
        
        // ナビゲーションを透明にする処理
       self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
       self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "使い方"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.brown]

    }

    // 開始するボタン押下時処理
    @objc private func tappedStartButton() {
      self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // 戻るボタン押下時処理
    @objc private func tappedbackButton() {
        self.dismiss(animated: true, completion: nil)
    }
        
}

extension UIView {
    func addBackgroundSeconds(name: String) {
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        // スクリーンサイズにあわせてimageViewの配置
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        //imageViewに背景画像を表示
        imageViewBackground.image = UIImage(named: name)
        
        // 画像の表示モードを変更。
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        // subviewをメインビューに追加
        self.addSubview(imageViewBackground)
        
        // 加えたsubviewを、最背面に設置する
        self.sendSubviewToBack(imageViewBackground)
    }
}

  

