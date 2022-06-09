//
//  QuestionViewController.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/03/18.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import SnapKit
import FirebaseAuth
import PKHUD

class QuestionViewController: UIViewController {

    private let QuestionTimeLinecellId = "QuestionTimeLinecellId"
    private var genle = [TimeLine]()
    var Genle: TimeLine?
    private var timeLineListner: ListenerRegistration?
    var TimeLineflag: Bool = false
    var loveflag: Bool = false
    var friendflag: Bool = false
    var workflag: Bool = false
    var otherflag: Bool = false
    var homeJudge = ""
    var blockId = ""
    var blockIdString: Array<String> = []

    //　恋愛ボタン押下時
    @IBAction func QuestionLoveButton(_ sender: UIButton) {
       QuestionLovefetchPostInfoFromFirestore()
    }
    //　ALLボタン押下時
    @IBAction func QuestionAllButton(_ sender: UIButton) {
        QuestionLovefetchPostInfoFromFirestore()
        QuestionWorkfetchPostInfoFromFirestore()
        QuestionOtherfetchPostInfoFromFirestore()
    }
    //　仕事ボタン押下時
    @IBAction func QuestionWorkButton(_ sender: UIButton) {
        QuestionWorkfetchPostInfoFromFirestore()
    }
    //　その他ボタン押下時
    @IBAction func QuestionOtherButton(_ sender: UIButton) {
        QuestionOtherfetchPostInfoFromFirestore()
    }
    //　マイタイムラインボタン押下時
    @IBAction func QuestionMyselfButton(_ sender: UIButton) {
        QuestionMyselfFetchPostInfoFromFirestore()
    }
    
    @IBOutlet weak var QuestionView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        QuestionView.delegate = self
        QuestionView.dataSource = self
        //　タイトル設定
        navigationItem.title = "質問箱"
        self.navigationController?.navigationBar.titleTextAttributes
               = [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 51/255, blue: 0/255, alpha: 1.0)]
        // 背景設定
        self.view.addBackground(name: "lightBackground")

        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
            
        // ユーザー情報が取得できない場合は初期登録画面へ遷移
        if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "TermsOfUse", bundle: nil)
            let TermsOfUseViewController = storyboar.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
            let nav = UINavigationController(rootViewController: TermsOfUseViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }
         
        //　ホームボタン設定
        let leftHomeButton = UIBarButtonItem(title: "ホーム", style: .plain, target: self, action: #selector(QtappedHomeButton))
        navigationItem.leftBarButtonItem = leftHomeButton
        navigationItem.leftBarButtonItem?.tintColor = .brown
    
        }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        QuestionLovefetchPostInfoFromFirestore()
        QuestionWorkfetchPostInfoFromFirestore()
        QuestionOtherfetchPostInfoFromFirestore()
        HUD.show(.progress)
        block()
    }
    
    
    // ブロックユーザー情報取得
    func block(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).collection("blockId").addSnapshotListener { ( snapshots, err) in
 
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let post = TimeLine.init(dic: dic)
                    guard let hideID = post.blockedId else { return }
                    self.blockIdString.append(hideID)
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            
        }
        
    }
        
    
    // ホームボタン押下時処理
    @objc private func QtappedHomeButton() {
        if (homeJudge == "homeJudge"){
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // 仕事質問表示
    private func QuestionWorkfetchPostInfoFromFirestore() {
        timeLineListner?.remove()
       genle.removeAll()
        QuestionView.reloadData()
        Firestore.firestore().collection("WorkQusetion").getDocuments { ( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            // ブッロクユーザー投稿を非表示
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                        
                    }
                    self.QuestionView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                        
                    }else{
                        self.genle.append(post)
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                        }
                        self.QuestionView.reloadData()
                    }
                    
                }
                
            })
        }
    }

    // 恋愛質問表示
    private func QuestionLovefetchPostInfoFromFirestore() {
        timeLineListner?.remove()
       genle.removeAll()
        QuestionView.reloadData()
        Firestore.firestore().collection("loveQusetion").getDocuments { ( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            // ブロックユーザー判定
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                        
                    }
                    self.QuestionView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                    
                    }else{
                        self.genle.append(post)
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                            
                        }
                        self.QuestionView.reloadData()
                    }
                    
                }
                
            })
        }
        
    }

    // その他質問表示
    private func QuestionOtherfetchPostInfoFromFirestore() {
        timeLineListner?.remove()
       genle.removeAll()
        QuestionView.reloadData()
        Firestore.firestore().collection("OtherQusetion").getDocuments { ( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            // ブッロクユーザー判定
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                        
                    }
                    self.QuestionView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                        
                    }else{
                        self.genle.append(post)
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                            
                        }
                        self.QuestionView.reloadData()
                    }
                    
                }
                
            })
        }
        
        
    }
    
    // 自身質問投稿処理
    private func QuestionMyselfFetchPostInfoFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        timeLineListner?.remove()
        genle.removeAll()
        QuestionView.reloadData()
                Firestore.firestore().collection("users").document(uid).collection("MyQusetion").addSnapshotListener { ( snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
                    let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
                    snapshots?.documents.forEach({ (snapshot) in
                        let dic = snapshot.data()
                        let post = TimeLine.init(dic: dic)
                        guard let hideID = post.uid else { return }
                        
                        
                        if(self.blockIdString.count == 0){
                            self.genle.append(post)
                            self.genle.sort { (m1, m2) -> Bool in
                                let m1Date = m1.createdAt.dateValue()
                                let m2Date = m2.createdAt.dateValue()
                                return m1Date > m2Date
                                
                            }
                            self.QuestionView.reloadData()
                            
                        }else{
                            if judgeBlock.contains(hideID) {
                                
                            }else{
                                self.genle.append(post)
                                self.genle.sort { (m1, m2) -> Bool in
                                    let m1Date = m1.createdAt.dateValue()
                                    let m2Date = m2.createdAt.dateValue()
                                    return m1Date > m2Date
                                    
                                }
                                self.QuestionView.reloadData()
                            }
                            
                        }
                        
                    })
                }
                
                
            }
}


    // MARK: - UITableViewDelegate, UITableViewDataSource
    extension QuestionViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            QuestionView.estimatedRowHeight = 80
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return genle.count
       
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = QuestionView.dequeueReusableCell(withIdentifier: QuestionTimeLinecellId, for: indexPath) as! QuestionTimeLinecell
              cell.Genle = genle[indexPath.row]
            return cell
   
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let storyboard = UIStoryboard.init(name: "QuestionThread", bundle: nil)
            let QuestionThreadViewController = storyboard.instantiateViewController(withIdentifier: "QuestionThreadViewController") as! QuestionThreadViewController
            tableView.deselectRow(at:indexPath,animated: true)
            QuestionThreadViewController.Genle = genle[indexPath.row]
                navigationController?.pushViewController(QuestionThreadViewController, animated: true)

        }
    }

class QuestionTimeLinecell: UITableViewCell {
   var Genle: TimeLine? {
        didSet {
            if let Posts = Genle {

                QuestionTimeLabel.text = dateFormatterForDateLabel(date: Posts.createdAt.dateValue())
                QuestionMessage.text = Posts.message
            }
        }
    }
        
    @IBOutlet weak var QuestionMessage: UILabel!
    @IBOutlet weak var QuestionTimeLabel: UILabel!
        
    override func awakeFromNib() {
                super.awakeFromNib()
    }
            
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
            
    private func dateFormatterForDateLabel(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
            
}


extension UIView {
    func addBackground11dfd11(name: String) {
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        // スクリーンサイズにあわせてimageViewの配置
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        // imageViewに背景画像を表示
        imageViewBackground.image = UIImage(named: name)
        
        // 画像の表示モードを変更。
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        // subviewをメインビューに追加
        self.addSubview(imageViewBackground)
        // 加えたsubviewを、最背面に設置する
        self.sendSubviewToBack(imageViewBackground)
    }
}
