//
//  HowToUse4.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/04/18.
//  Copyright © 2021 吉田　知代. All rights reserved.
//


import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD
import Nuke
import SnapKit

class HowToUseSecondController: UIViewController {
    
    @IBOutlet weak var HowToUseSecondTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackgroundSecond(name: "useFirst")
        
        let image = UIImage(named: "howToUseSecond.jpg")
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = image
        self.HowToUseSecondTableView.backgroundView = imageView
        
        
        let rigth4HomeButton = UIBarButtonItem(title: "開始する", style: .plain, target: self, action: #selector(tappedStartButton))
        navigationItem.rightBarButtonItem = rigth4HomeButton
        navigationItem.rightBarButtonItem?.tintColor = .brown
        let backButton = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(tappedbackButton))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = .brown
        
        navigationItem.title = "使い方"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.brown]
        
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    @objc private func tappedStartButton() {
        createUserToFirestore()
        
    }
    
    @objc private func tappedbackButton() {
        let storyboar = UIStoryboard(name: "HowToUse1", bundle: nil)
        let HowToUsefirstController = storyboar.instantiateViewController(withIdentifier: "HowToUsefirstController") as! HowToUsefirstController
        let nav = UINavigationController(rootViewController: HowToUsefirstController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    // ユーザー情報登録処理
    private func createUserToFirestore() {
        Auth.auth().signInAnonymously() { authResult, error in
            guard let uid = authResult?.user.uid else { return }
            
            let docData = [
                "createdAt": Timestamp(),
                "displayName":"ことり",
                "uid": uid
                
            ] as [String : Any]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                HUD.hide()
                // ホーム画面へ遷移
                let storyboar = UIStoryboard(name: "Home", bundle: nil)
                let HomeTableViewController = storyboar.instantiateViewController(withIdentifier: "HomeTableViewController") as! HomeTableViewController
                let nav = UINavigationController(rootViewController: HomeTableViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
                
            }
        }
    }
    
}
extension UIView {
    func addBackgroundSecond(name: String) {
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
