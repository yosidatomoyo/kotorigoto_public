//
//  QuestionThreadViewController.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/05/07.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import SnapKit
import FirebaseAuth
import PKHUD

class QuestionThreadViewController: UIViewController , UITextViewDelegate{
    
    private let QuestionThreadViewCellId = "QuestionThreadViewCellId"
    private var QuestionThreaListner: ListenerRegistration?
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    
    var user: User?
    var Genle: TimeLine?
    var genle = [TimeLine]()
    var messages = [Message]()
    var name = ""
    private let accessoryHeight: CGFloat = 100
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    private let placeholder = ""
    private let textLength = 150
    var blockId = ""
    var blockIdString: Array<String> = []
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var QuestionThreadView: UITableView!
    @IBOutlet weak var ThreadTextView: UITextView!
    
    // 解答エリアが空の場合はボタン非活性
    @IBAction func SendButton(_ sender: UIButton) {
        ThreadTextView.text = ""
        sendButton.isEnabled = false
    }
    
    // 送信ボタン押下時処理
    @IBAction func sendButtonDown(_ sender: UIButton) {
        guard let text = ThreadTextView.text else { return }
        ThreadPostaddMessageToFirestore(text:text)
        ThreadTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QuestionThreadView.delegate = self
        QuestionThreadView.dataSource = self
        navigationItem.title = "回答"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 51/255, blue: 0/255, alpha: 1.0)]
        sendButton.isEnabled = false
        self.view.addBackground(name: "lightBackground")
        
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        setupNotification()
        ThreadTextView.text = placeholder
        self.ThreadTextView.delegate = self
        
        // ユーザー情報が取得できない場合は初期登録画面へ遷移
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
        fetchQuestionine()
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
    
    // 文字数制限＆行数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 既に存在する改行数
        let existingLines = textView.text.components(separatedBy: .newlines)
        // 新規改行数
        let newLines = text.components(separatedBy: .newlines)
        // 最終改行数。-1は編集したら必ず1改行としてカウントされる
        let linesAfterChange = existingLines.count + newLines.count - 1
        return linesAfterChange <= 7 && ThreadTextView.text.count + (text.count - range.length) <= textLength
    }
    
    // TextViewの内容が変わるたびに実行される
    func textViewDidChange(_ textView: UITextView) {
        if ThreadTextView.text == "" {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
    }
    
    // キーボード表示処理
    @objc func keyboardWillShow(notification: NSNotification) {
        if !ThreadTextView.isFirstResponder {
            return
        }
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardRect.height
            }
        }
    }
    
    // キーボード非表示処理
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        self.view.endEditing(true)
    }
    
    // 解答情報をデータベースに保存
    private func ThreadPostaddMessageToFirestore(text: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let QestionThreadDocId = Genle?.ThreadRoomId else { return }
        
        if (uid == Genle?.uid){
            name = "質問者"
        }else {
            name = "回答者"
        }
        let messageId = randomString(length: 20)
        let docDataPost = [
            "uid": uid,
            "name":name,
            "message": text,
            "createdAt": Timestamp(),
            "messageId":messageId,
        ] as [String : Any]
        Firestore.firestore().collection("Thread").document(QestionThreadDocId).collection("Thread").addDocument(data: docDataPost) { (err) in
        }
    }
    
    // 乱数生成
    private func randomString(length: Int) -> String {
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
    
    // 質問情報取得
    private func fetchQuestionine(){
        guard let QestionThreadDocId = Genle?.ThreadRoomId else { return }
        
        QuestionThreaListner?.remove()
        messages.removeAll()
        QuestionThreadView.reloadData()
        Firestore.firestore().collection("Thread").document(QestionThreadDocId).collection("Thread").addSnapshotListener { ( snapshots, err) in
            HUD.hide()
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message.init(dic: dic)
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                    self.QuestionThreadView.reloadData()
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
}




// MARK: - UITableViewDelegate, UITableViewDataSource
extension QuestionThreadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        QuestionThreadView.estimatedRowHeight = 120
        return UITableView.automaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = QuestionThreadView.dequeueReusableCell(withIdentifier: QuestionThreadViewCellId, for: indexPath) as! QuestionThreadViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = QuestionThreadView.dequeueReusableCell(withIdentifier: QuestionThreadViewCellId, for: indexPath) as! QuestionThreadViewCell
        cell.message = messages[indexPath.row]
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let blockId = cell.message?.uid else { return }
        alertGenerate()
        
        // ブロック・通報
        func alertGenerate(){
            // アラート生成
            // UIAlertControllerのスタイルがactionSheet
            let actionSheet = UIAlertController(title: "ブロック・通報", message: "", preferredStyle: UIAlertController.Style.actionSheet)
            
            // ユーザーブロックボタンが押された時の処理をクロージャ実装
            let action1 = UIAlertAction(title: "ユーザーブロック", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                // 確認メッセージ
                alert()
            })
            // 通報2ボタンが押された時の処理をクロージャ実装
            let action2 = UIAlertAction(title: "通報", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                // 確認メッセージ
                Report()
                
                
            })
            
            // 閉じるボタンが押された時の処理をクロージャ実装
            // UIAlertActionのスタイルがCancelなので赤く表示
            let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.destructive, handler: {
                (action: UIAlertAction!) in
            })
            
            //UIAlertControllerにブロックボタンと通報ボタンと閉じるボタンをActionを追加
            actionSheet.addAction(action1)
            actionSheet.addAction(action2)
            actionSheet.addAction(close)
            // iPad の場合のみ、ActionSheetを表示
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = self.view
                let screenSize = UIScreen.main.bounds
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
            }
            // 実際にAlertを表示する
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        func reportAlertGenerate(){
            //アラート生成
            let alert: UIAlertController = UIAlertController(title: "通報してもよろしいですか？", message:  "", preferredStyle:  UIAlertController.Style.alert)
            // 通報するボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "通報する", style: UIAlertAction.Style.default, handler:{
                // 通報するボタンが押された時の処理をクロージャ実装
                (action: UIAlertAction!) -> Void in
                // 通報処理
                RunAlert()
            })
            
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装
                (action: UIAlertAction!) -> Void in
            })
            
            // UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            // 実際にAlertを表示する
            present(alert, animated: true, completion: nil)
        }
        
        // ブロック処理
        func alert(){
            // アラート生成
            // UIAlertControllerのスタイルがalert
            let alert: UIAlertController = UIAlertController(title: "ブロックしてもよろしいですか？", message:  "", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "ブロックする", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                // ブロック処理
                blocked()
                
            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
            })
            
            // UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            // 実際にAlertを表示する
            present(alert, animated: true, completion: nil)
        }
        
        // ブロック処理
        func blocked(){
            // 自身の投稿の場合ブロックしない
            if(uid == blockId){
                let alert = UIAlertController(title: "自身の投稿のためできません", message: "自身の投稿のためできません", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }else{
                let blockIdData = [
                    "blockedId": blockId,
                    "uid":uid
                ]
                Firestore.firestore().collection("users").document(uid).collection("blockId").document(blockId).setData(blockIdData){ (err) in
                }
                let alert = UIAlertController(title: "ブロックしました", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        func Report(){
            reportAlertGenerate()
        }
        
        // 通報処理
        func RunAlert(){
            // 自身の投稿の場合通報しない
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
                    
                }
                let alert = UIAlertController(title: "通報しました", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


class QuestionThreadViewCell: UITableViewCell {
    var message: Message?{
        didSet {
            if let message = message {
                nameLabel.text = message.name
                latestQestionMessage.text = message.message
                QuestionTimeLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                
            }
        }
    }
    
    @IBOutlet weak var latestQestionMessage: UILabel!
    @IBOutlet weak var QuestionTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
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
    func addBackground11fdfd11(name: String) {
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
