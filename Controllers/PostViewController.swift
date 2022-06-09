//
//  PostViewController.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/03/08.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import SnapKit
import FirebaseAuth
import PKHUD

class PostViewController: UIViewController, UITextViewDelegate {
    
    private var genle = [TimeLine]()
    private var user = [User]()

    var TimeLineflag: Bool = false
    var Questionflag: Bool = false
    var loveflag: Bool = false
    var friendflag: Bool = false
    var workflag: Bool = false
    var otherflag: Bool = false
    var privateflag: Bool = false
    var sendButtonFlag = true
    private let placeholder = ""
    private let textLength = 150

    @IBOutlet weak var PostTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBAction func tappedSendButton(_ sender: Any) {
        
    sendButton.isEnabled = false
    
    // 投稿テキストエリアから判定
    if (PostTextView.text == "") {
        sendButton.isEnabled = false
    } else {
        sendButton.isEnabled = true
    }
    
    sendButtonFlag = false
    HUD.show(.progress, onView: view)
        
    // 二重送信防止
    if (sendButtonFlag != true) {
        sendButton.isEnabled = false
    }
        
    guard let text = PostTextView.text else { return }
    CheckaddPostToFirestore(text:text)
        
    }
    
  
    // タイムライン、質問判定
    @IBAction func SelctionButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            TimeLineflag = true
            Questionflag = false
            privateflag = false

        case 1:
            Questionflag = true
            TimeLineflag = false
            privateflag = false

        case 2:
            privateflag = true
            TimeLineflag = false
            Questionflag = false
            
        default:
            TimeLineflag = false
            Questionflag = false

        }
    }
    
    // 投稿ジャンル判定
    @IBAction func SelectionGenleButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loveflag = true
            friendflag = false
            workflag = false
            otherflag = false
        case 1:
            workflag = true
            loveflag = false
            friendflag = false
            otherflag = false
        case 2:
            otherflag = true
            loveflag = false
            friendflag = false
            otherflag = false
            
        default:
            friendflag = false
            workflag = false
            otherflag = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタン背景色設定
        let rgba = UIColor(red: 0/255, green: 220/255, blue: 0/255, alpha: 1.0)
        // 背景色
        sendButton.backgroundColor = rgba
        // 枠線の幅
        sendButton.layer.borderWidth = 1
        // 枠線の色
        sendButton.layer.borderColor = UIColor.green.cgColor
        // 角丸のサイズ
        sendButton.layer.cornerRadius = 10.0
        // タイトルの色
        sendButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        
        PostTextView.text = placeholder
        self.PostTextView.delegate = self
        sendButton.isEnabled = false
        self.view.addBackground1(name: "background.jpg")
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide1))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        navigationItem.title = "投稿"
        self.navigationController?.navigationBar.titleTextAttributes
               = [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 51/255, blue: 0/255, alpha: 1.0)]
        // ナビゲーションを透明にする処理
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
       
        let leftHomeButton = UIBarButtonItem(title: "ホーム", style: .plain, target: self, action: #selector(PtappedHomeButton))
        navigationItem.leftBarButtonItem = leftHomeButton
        navigationItem.leftBarButtonItem?.tintColor = .brown
        
        // ユーザー情報が取得できない場合初期登録画面へ遷移
        if Auth.auth().currentUser?.uid == nil {
            let storyboar = UIStoryboard(name: "TermsOfUse", bundle: nil)
            let TermsOfUseViewController = storyboar.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
            let nav = UINavigationController(rootViewController: TermsOfUseViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    @objc func keyboardWillHide1() {
        self.view.endEditing(true)
    }
  
    // 文字数制限＆行数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 既に存在する改行数
        let existingLines = textView.text.components(separatedBy: .newlines)
        // 新規改行数
        let newLines = text.components(separatedBy: .newlines)
        // 最終改行数。-1は編集したら必ず1改行としてカウントされる
        let linesAfterChange = existingLines.count + newLines.count - 1

        return linesAfterChange <= 7 && PostTextView.text.count + (text.count - range.length) <= textLength
    }

    // TextViewの内容が変わるたびに実行される
    func textViewDidChange(_ textView: UITextView) {
        // 既に存在する改行数
        let existingLines = textView.text.components(separatedBy: .newlines)
        if existingLines.count <= 7 {
            self.wordCountLabel.text = "\(PostTextView.text.count) / \(textLength)"
            
            if PostTextView.text == "" {
                sendButton.isEnabled = false
               } else {
                sendButton.isEnabled = true
               }
        }
    }

    // 入力開始時にプレースホルダーの内容が入っていたら空にする
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = nil
            textView.textColor = .darkText
        }
    }

    // 入力終了後に文字が入力されていなかったらプレースホルダー表示
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = .darkGray
        }
    }

    func setupTextView() {
        // キーボードの上に置くツールバーの生成
        let toolBar = UIToolbar()
        // 右端にDoneボタンを置きたいので、左に空白を入れる
        let flexibleSpaceBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // Doneボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        // ツールバーにボタンを配置
        toolBar.items = [flexibleSpaceBarButton, doneButton]
        toolBar.sizeToFit()
        // テキストビューにツールバーをセット
        PostTextView.inputAccessoryView = toolBar
    }
    
    @objc private func PtappedHomeButton() {
        self.dismiss(animated: true, completion: nil)
    }
    // キーボードを閉じる処理。
    @objc func dismissKeyboard() {
        PostTextView.resignFirstResponder()
    }
    
    // 投稿種類フラグ判定
    private func CheckaddPostToFirestore(text: String){
        print(TimeLineflag)
        if ( TimeLineflag == true ) {
            guard let text = PostTextView.text else { return }
            addPostTimeLineFirestore(text:text)
        } else {
        }
        
        if ( Questionflag == true  ) {
            guard let text = PostTextView.text else { return }
            addPostQuestionFirestore(text:text)
        } else {
        }
        if ( privateflag == true  ) {
            guard let text = PostTextView.text else { return }
            addPostPrivateflagFirestore(text:text)
        } else {
        }
    }
    
    // 投稿ジャンルフラグ判定
    private func addPostTimeLineFirestore(text: String){
        if ( workflag ) {
            workTimelineaddPost(text:text)
        }
        else if ( loveflag ){
            loveTimelineaddPost(text:text)
        }else {
            otherTimelineaddPost(text:text)
        }
    }
    
    // タイムライン画面へ遷移
    func transitionTimeLine(){
        let storyboar = UIStoryboard(name: "TimeLine", bundle: nil)
        let TimeLineViewController = storyboar.instantiateViewController(withIdentifier: "TimeLineViewController") as! TimeLineViewController
        let nav = UINavigationController(rootViewController: TimeLineViewController)
        nav.modalPresentationStyle = .fullScreen
        TimeLineViewController.homeJudge = "homeJudge"
        self.present(nav, animated: false, completion: nil)
    }
    
    // 質問画面へ遷移
    func transitionQuestion(){
        let storyboar = UIStoryboard(name: "Question", bundle: nil)
        let QuestionViewController = storyboar.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        let nav = UINavigationController(rootViewController: QuestionViewController)
        nav.modalPresentationStyle = .fullScreen
        QuestionViewController.homeJudge = "homeJudge"
        self.present(nav, animated: false, completion: nil)
    }
    
    //　仕事タイムライン投稿処理
    private  func workTimelineaddPost(text: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        
        let docDataPost = [
            "uid": uid,
            "message": text,
            "createdAt": Timestamp(),
            "MessageId":  MessageId,
            "blockedId": "",
            "genle":"WorkTimeLine"

        ] as [String : Any]
        
        Firestore.firestore().collection("WorkTimeLine").document(MessageId).setData(docDataPost){ (err) in
            self.transitionTimeLine()
        }
        
        Firestore.firestore().collection("users").document(uid).collection("MyTimeLine").document(MessageId).setData(docDataPost){ (err) in

        }
    }
    
    //　恋愛タイムライン投稿処理
    private func loveTimelineaddPost(text: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        let docDataPost = [
            "uid": uid,
            "message": text,
            "createdAt": Timestamp(),
            "MessageId": MessageId,
            "blockedId": "",
            "genle":"loveTimeLine"
        ] as [String : Any]

        Firestore.firestore().collection("loveTimeLine").document(MessageId).setData(docDataPost){ (err) in
            if let err = err {
                print("投稿情報の保存に失敗しました。\(err)")
                return
            }
            self.transitionTimeLine()
        }

        Firestore.firestore().collection("users").document(uid).collection("MyTimeLine").document(MessageId).setData(docDataPost){ (err) in
            if let err = err {
                print("投稿情報の保存に失敗しました。\(err)")
                return
            }
           
        }
    }
    //　その他タイムライン投稿処理
    private func otherTimelineaddPost(text: String){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        
        let docDataPost = [
            "uid": uid,
            "message": text,
            "createdAt": Timestamp(),
            "MessageId": MessageId,
            "blockedId": "",
            "genle":"OtherTimeline"

        ] as [String : Any]
        
        Firestore.firestore().collection("OtherTimeline").document(MessageId).setData(docDataPost){ (err) in
            self.transitionTimeLine()
        }
        
        Firestore.firestore().collection("users").document(uid).collection("MyTimeLine").document(MessageId).setData(docDataPost){ (err) in
        }
    }
    
    //　質問ジャンル判定
    private func addPostQuestionFirestore(text: String){
       if ( workflag ) {
            workQusetionaddPost(text:text)
        }
        else if ( loveflag ){
            loveQusetionaddPost(text:text)
        }else {
            otherQusetionaddPost(text:text)
        }
    }
    
    //　仕事質問投稿処理
    private func workQusetionaddPost(text: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        let ThreadRoomId = randomString(length: 20)
        let docDataPost = [
            "uid": uid,
            "message": text,
            "name" : "質問文",
            "createdAt": Timestamp(),
            "ThreadRoomId":ThreadRoomId,
            "MessageId": MessageId,
            "blockedId": "",
            "genle":"WorkQusetion"

        ] as [String : Any]
        
        Firestore.firestore().collection("WorkQusetion").document(MessageId).setData(docDataPost){ (err) in
            self.transitionQuestion()
        }
        
        Firestore.firestore().collection("users").document(uid).collection("MyQusetion").document(MessageId).setData(docDataPost){ (err) in
        }
        
        Firestore.firestore().collection("Thread").document(ThreadRoomId).collection("Thread").addDocument(data: docDataPost) { (err) in
        }
    }
    
    //　恋愛質問投稿処理
    private  func loveQusetionaddPost(text: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        let ThreadRoomId = randomString(length: 20)

        let docDataPost = [
            "uid": uid,
            "message": text,
            "name" : "質問文",
            "createdAt": Timestamp(),
            "ThreadRoomId":ThreadRoomId,
            "MessageId": MessageId,
            "blockedId": "",
            "genle":"loveQusetion"

        ] as [String : Any]
        
        Firestore.firestore().collection("loveQusetion").document(MessageId).setData(docDataPost){ (err) in
            self.transitionQuestion()
        }
        
        Firestore.firestore().collection("users").document(uid).collection("MyQusetion").document(MessageId).setData(docDataPost){ (err) in
        }
        
        Firestore.firestore().collection("Thread").document(ThreadRoomId).collection("Thread").addDocument(data: docDataPost) { (err) in
        }
    }
    
    private func otherQusetionaddPost(text: String){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        let ThreadRoomId = randomString(length: 20)
        let docDataPost = [
            "uid": uid,
            "message": text,
            "name" : "質問文",
            "createdAt": Timestamp(),
            "ThreadRoomId":ThreadRoomId,
            "MessageId": MessageId,
            "blockedId": "",
            "genle":"OtherQusetion"
            
        ] as [String : Any]
        
        Firestore.firestore().collection("OtherQusetion").document(MessageId).setData(docDataPost){ (err) in
            self.transitionQuestion()
        }
        Firestore.firestore().collection("users").document(uid).collection("MyQusetion").document(MessageId).setData(docDataPost){ (err) in
        }
        Firestore.firestore().collection("Thread").document(ThreadRoomId).collection("Thread").addDocument(data: docDataPost) { (err) in

        }
    }
    
    //　個人投稿投稿処理
    private func  addPostPrivateflagFirestore(text: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let MessageId = randomString(length: 20)
        
        let docDataPost = [
            "uid": uid,
            "message": text,
            "createdAt": Timestamp(),
            "messageId": MessageId

        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).collection("MyTimeLine").document(MessageId).setData(docDataPost){ (err) in
            self.transitionTimeLine()
        }
    }
    
    //　乱数生成
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
}


extension UIView {
    func addBackground1(name: String) {
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

