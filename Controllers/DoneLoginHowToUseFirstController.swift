//
//  DoneLoginHowToUse1.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/05/23.
//  Copyright © 2021 吉田　知代. All rights reserved.
//



import UIKit

class DoneLoginHowToUseFirstController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景の設定
        self.view.addBackgrounduse1(name: "useFirst")
        let image = UIImage(named: "howToUseFirst.jpg")
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = image
        self.tableView.backgroundView = imageView
        
        let rigth1HomeButton = UIBarButtonItem(title: "次へ", style: .plain, target: self, action: #selector(tappedNextButton))
        navigationItem.rightBarButtonItem = rigth1HomeButton
        navigationItem.rightBarButtonItem?.tintColor = .brown
        
        navigationItem.title = "使い方"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.brown]
        
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    // 次へボタン押下時処理
    @objc private func tappedNextButton() {
        let storyboar = UIStoryboard(name: "DoneLoginHowToUseSecondController", bundle: nil)
        let DoneLoginHowToUseSecondController = storyboar.instantiateViewController(withIdentifier: "DoneLoginHowToUseSecondController") as! DoneLoginHowToUseSecondController
        let nav = UINavigationController(rootViewController: DoneLoginHowToUseSecondController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav,animated: true, completion: nil)
    }
}


extension UIView {
    func addBackgrounduse1(name: String) {
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

extension UIView {
    func addBackgrounduser1(name: String) {
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
