//
//  TimeLineViewController.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/02/28.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import SnapKit
import FirebaseAuth
import PKHUD

class TimeLineViewController: UIViewController {
    
    private let TimeLinecellId = "TimeLinecellId"
    private var timeLineListner: ListenerRegistration?
    
    var Genle: TimeLine?
    var genle = [TimeLine]()
    var user : User?
    var users = [User]()
    var TimeLineflag: Bool = false
    var loveflag: Bool = false
    var friendflag: Bool = false
    var workflag: Bool = false
    var otherflag: Bool = false
    var homeJudge = ""
    var blockId = ""
    var blockIdString: Array<String> = []
    
    private var Posts: TimeLine? {
        didSet {
        }
    }
    
    private var x: User? {
        didSet {
        }
    }
    
    // 恋愛ボタン押下
    @IBAction func TimeLineLoveButton(_ sender: UIButton) {
        fetchTimeLineLove()
    }
    // 自分の投稿ボタン押下
    @IBAction func TimeLineMyButton(_ sender: UIButton) {
        fetchTimeLineMy()
    }
    // 仕事ボタン押下
    @IBAction func TimeLineWorkButoon(_ sender: UIButton) {
        fetchTimeLineWork()
    }
    // その他ボタン押下
    @IBAction func TimeLineOtherButton(_ sender: UIButton) {
        fetchTimeLineOther()
    }
    // ALLボタン押下
    @IBAction func allDisplay(_ sender: UIButton) {
        fetchTimeLineLove()
        fetchTimeLineWork()
        fetchTimeLineOther()
    }
    @IBOutlet weak var TimeLineTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground(name: "1111")
        TimeLineTableView.delegate = self
        TimeLineTableView.dataSource = self
        
        // タイムラインラベル設定
        navigationItem.title = "タイムライン"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 51/255, blue: 0/255, alpha: 1.0)]
        
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let leftHomeButton = UIBarButtonItem(title: "ホーム", style: .plain, target: self, action: #selector(TtappedHomeButton))
        navigationItem.leftBarButtonItem = leftHomeButton
        navigationItem.leftBarButtonItem?.tintColor = .brown
        
        // ユーザ情報がNULLの場合初期登録画面へ遷移
        if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "TermsOfUse", bundle: nil)
            let TermsOfUseViewController = storyboar.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
            let nav = UINavigationController(rootViewController: TermsOfUseViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HUD.show(.progress, onView: view)
        fetchTimeLineLove()
        fetchTimeLineWork()
        fetchTimeLineOther()
        block()
        
    }
    
    func block(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).collection("blockId").addSnapshotListener { ( snapshots, err) in
            
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
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
    @objc private func TtappedHomeButton() {
        if (homeJudge == "homeJudge"){
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // マイタイムライン表示処理
    private func fetchTimeLineMy(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        timeLineListner?.remove()
        genle.removeAll()
        TimeLineTableView.reloadData()
        // マイタイムライン情報取得
        Firestore.firestore().collection("users").document(uid).collection("MyTimeLine").addSnapshotListener { ( snapshots, err) in
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let post = TimeLine.init(dic: dic)
                    self.genle.append(post)
                    // 投稿順に並び替え
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.TimeLineTableView.reloadData()
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            
        }
        
    }
    
    
    // 仕事タイムライン表示処理
    private func fetchTimeLineWork() {
        timeLineListner?.remove()
        genle.removeAll()
        TimeLineTableView.reloadData()
        // 仕事タイムライン情報取得
        Firestore.firestore().collection("WorkTimeLine").getDocuments { ( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                // ブロックユーザー判定
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.TimeLineTableView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                        
                    }else{
                        self.genle.append(post)
                        // 昇順に並び替え
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                            
                        }
                        self.TimeLineTableView.reloadData()
                    }
                    
                }
                
            })
        }
        
        
    }
    
    // 恋愛タイムライン表示処理
    private func fetchTimeLineLove() {
        timeLineListner?.remove()
        genle.removeAll()
        TimeLineTableView.reloadData()
        // 恋愛タイムライン情報取得
        Firestore.firestore().collection("loveTimeLine").getDocuments {( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                // ブロックユーザー判定
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                        
                    }
                    self.TimeLineTableView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                        
                    }else{
                        self.genle.append(post)
                        // 昇順に並び替え
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                            
                        }
                        self.TimeLineTableView.reloadData()
                    }
                    
                }
                
            })
        }
        
        
    }
    
    // その他タイムライン表示処理
    private func fetchTimeLineOther() {
        timeLineListner?.remove()
        genle.removeAll()
        TimeLineTableView.reloadData()
        // その他タイムライン情報取得
        Firestore.firestore().collection("OtherTimeline").getDocuments { ( snapshots, err) in
            if let err = err {
                print("post情報の取得に失敗しました。\(err)")
                return
            }
            HUD.hide()
            let judgeBlock = self.blockIdString.reduce("") { $0 + String($1) }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let post = TimeLine.init(dic: dic)
                guard let hideID = post.uid else { return }
                
                // ブロックユーザー判定
                if(self.blockIdString.count == 0){
                    self.genle.append(post)
                    self.genle.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                        
                    }
                    self.TimeLineTableView.reloadData()
                    
                }else{
                    if judgeBlock.contains(hideID) {
                        
                    }else{
                        self.genle.append(post)
                        self.genle.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                            
                        }
                        self.TimeLineTableView.reloadData()
                    }
                    
                }
                
            })
        }
        
        
    }
    
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        TimeLineTableView.estimatedRowHeight = 120
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genle.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TimeLineTableView.dequeueReusableCell(withIdentifier: TimeLinecellId, for: indexPath) as! TimeLineTableViewCell
        cell.Posts = genle[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = TimeLineTableView.dequeueReusableCell(withIdentifier: TimeLinecellId, for: indexPath) as! TimeLineTableViewCell
        cell.Posts = genle[indexPath.row]
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let blockId = cell.Posts?.uid else { return }
        alertGenerate()
        
        // ブロック通報処理
        func alertGenerate(){
            // アラート生成
            // UIAlertControllerのスタイルがactionSheet
            let actionSheet = UIAlertController(title: "通報・ブロック", message: "", preferredStyle: UIAlertController.Style.actionSheet)
            
            // ブロックボタンが押された時の処理をクロージャ実装する
            let action1 = UIAlertAction(title: "ユーザーブロック", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                // 実際の処理
                alert()
            })
            // 通報ボタンが押された時の処理をクロージャ実装する
            let action2 = UIAlertAction(title: "通報", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                // 実際の処理
                Report()
            })
            
            // 閉じるボタンが押された時の処理をクロージャ実装する
            // UIAlertActionのスタイルがCancelなので赤く表示される
            let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.destructive, handler: {
                (action: UIAlertAction!) in
                // 実際の処理
                print("閉じる")
            })
            
            actionSheet.addAction(action1)
            actionSheet.addAction(action2)
            actionSheet.addAction(close)
            // iPad の場合のみ、ActionSheetを表示するための必要な設定
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height,width: 0,height: 0)
            }
            // 実際にAlertを表示する
            self.present(actionSheet, animated: true, completion: nil)
            
        }
        
        func Report(){
            reportAlertGenerate()
        }
        
        // 確認アラート
        func alert(){
            // アラート生成
            let alert: UIAlertController = UIAlertController(title: "ブロックしてもよろしいですか？", message:"", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "ブロックする", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                blocked()
                
            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                // 実際の処理
                print("キャンセル")
            })
            
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            // 実際にAlertを表示する
            present(alert, animated: true, completion: nil)
        }
        
        
        // 確認アラート
        func reportAlertGenerate(){
            // アラート生成
            // UIAlertControllerのスタイルがalert
            let alert: UIAlertController = UIAlertController(title: "通報してもよろしいですか？", message:  "", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "通報する", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                // 実際の処理
                print("確定")
                RunAlert()
                
                
            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                print("キャンセル")
            })
            
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            //実際にAlertを表示する
            present(alert, animated: true, completion: nil)
        }
        
        
        // ブロック処理
        func blocked(){
            // 自身の投稿の場合ブロックしない
            if(uid == blockId){
                let alert = UIAlertController(title: "自身の投稿のためできません", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }else{
                // ブロックユーザー情報を登録
                let blockIdData = [
                    "blockedId": blockId,
                    "uid":uid
                ]
                Firestore.firestore().collection("users").document(uid).collection("blockId").document(blockId).setData(blockIdData){ (err) in
                    if let err = err {
                        print("最新メッセージの保存に失敗しました。\(err)")
                        return
                    }
                    print("メッセージの保存に成功しました。")
                    self.fetchTimeLineLove()
                    self.fetchTimeLineWork()
                    self.fetchTimeLineOther()
                    self.block()
                }
                let alert = UIAlertController(title: "ブロック完了しました", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // 乱数生成
        func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)
            var randomString = ""
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
        }
        
        // 処理完了メッセージ表示
        func RunAlert(){
            if(uid == blockId){
                let alert = UIAlertController(title: "自身の投稿のためできません", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alertId = randomString(length: 20)
                
                let alertData = [
                    "alertId": blockId,
                    "ReporterID":uid,
                    "createdAt": Timestamp()
                ] as [String : Any]
                Firestore.firestore().collection("Report").document(alertId).setData(alertData){ (err) in
                    if let err = err {
                        print("最新メッセージの保存に失敗しました。\(err)")
                        return
                    }
                    print("メッセージの保存に成功しました。")
                }
                
                let alert = UIAlertController(title: "通報しました", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
}


class TimeLineTableViewCell: UITableViewCell {
    
    var Posts: TimeLine? {
        didSet {
            if let Posts = Posts {
                
                timelabel.text = dateFormatterForDateLabel(date: Posts.createdAt.dateValue())
                TimeLineLatestMessage.text = Posts.message
            }
        }
    }
    
    
    @IBOutlet weak var TimeLineLatestMessage: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    
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
    func addBackground1111(name: String) {
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
