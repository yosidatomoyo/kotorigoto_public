//
//  HowToUsefirst.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/04/18.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit

class HowToUsefirstController: UIViewController {
    
    @IBOutlet weak var HowToUsefirstTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景設定
        self.view.addBackgroundufirst(name: "useFirst")
        let image = UIImage(named: "howToUseFirst.jpg")
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = image
        self.HowToUsefirstTableView.backgroundView = imageView
        navigationItem.title = "使い方"
        
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 51/255, blue: 0/255, alpha: 1.0)]
        
        // 次へボタン設定
        let rigth1HomeButton = UIBarButtonItem(title: "次へ", style: .plain, target: self, action: #selector(tappedNextButton))
        navigationItem.rightBarButtonItem = rigth1HomeButton
        navigationItem.rightBarButtonItem?.tintColor = .brown
        
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // 次へボタン押下時処理
    @objc private func tappedNextButton() {
        let storyboar = UIStoryboard(name: "HowToUse4", bundle: nil)
        let HowToUseSecondController = storyboar.instantiateViewController(withIdentifier: "HowToUseSecondController") as! HowToUseSecondController
        let nav = UINavigationController(rootViewController: HowToUseSecondController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav,animated: true, completion: nil)
    }
}

extension UIView {
    func addBackgroundufirst(name: String) {
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
