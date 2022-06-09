//
//  HomeTableViewController.swift
//  ChatAppWithFirebase
//　ホーム画面
//  Created by 吉田知代 on 2021/04/27.
//  Copyright © 2021 吉田　知代. All rights reserved.
//


import UIKit
import Firebase
import Nuke
import SnapKit
import FirebaseAuth


class HomeTableViewController: UIViewController ,UITabBarDelegate{
    
    private let TimeLinecellId = "TimeLinecellId"
    private let TimeLineButtoncellId = "TimeLineButtoncellId"
    private var genle = [TimeLine]()
    
    private var timeLineListner: ListenerRegistration?
    var Loveflag: Bool = false
    var Workflag: Bool = false
    
    // タイムラインボタン押下時
    @IBAction func TimeLineButton(_ sender: UIButton) {
        let storyboar = UIStoryboard(name: "TimeLine", bundle: nil)
        let TimeLineViewController = storyboar.instantiateViewController(withIdentifier: "TimeLineViewController") as! TimeLineViewController
        let nav = UINavigationController(rootViewController: TimeLineViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    // 質問ボタン押下時
    @IBAction func QuestionButton(_ sender: UIButton) {
        let storyboar = UIStoryboard(name: "Question", bundle: nil)
        let QuestionViewController = storyboar.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        let nav = UINavigationController(rootViewController: QuestionViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    // 投稿ボタン押下時
    @IBAction func PostButton(_ sender: UIButton) {
        let storyboar = UIStoryboard(name: "Post", bundle: nil)
        let PostViewController = storyboar.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        let nav = UINavigationController(rootViewController: PostViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    // その他ボタン押下時
    @IBAction func OtherButton(_ sender: UIButton) {
        otherButton()
    }
    
    // 初期起動時実行
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景設定
        self.view.addBackground(name: "home")
        
        // ユーザー情報が存在しない場合登録画面へ遷移（利用規約）
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        fetchedefoltMessage()
        
    }
    
    // 小鳥の一言ボタン押下時
    @IBAction func messageButton(_ sender: Any) {
        fetcheMessage()
    }
    
    // その他のボタン押下時処理関数
    private func otherButton(){
        let actionSheet = UIAlertController(title: "その他", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        // 使い方押下時
        let actionHowToUse = UIAlertAction(title: "使い方", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyboar = UIStoryboard(name: "DoneLoginHowToUseFirst", bundle: nil)
            let DoneLoginHowToUseFirstController = storyboar.instantiateViewController(withIdentifier: "DoneLoginHowToUseFirst") as! DoneLoginHowToUseFirstController
            let nav = UINavigationController(rootViewController: DoneLoginHowToUseFirstController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        })
        
        // お問い合わせ押下時
        let actionInquiry = UIAlertAction(title: "お問い合わせ", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            // Twitterに遷移
            let url = NSURL(string: "https://mobile.twitter.com/yoshidatwitt")
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            
        })
        
        // 利用規約押下時
        let actionTermsOfUse = UIAlertAction(title: "利用規約", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let storyboar = UIStoryboard(name: "DoneTermsOfUse", bundle: nil)
            let DoneTermsOfUseViewController = storyboar.instantiateViewController(withIdentifier: "DoneTermsOfUseViewController") as! DoneTermsOfUseViewController
            let nav = UINavigationController(rootViewController: DoneTermsOfUseViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        })
        
        // 初期化押下時
        let actionReset = UIAlertAction(title: "初期化", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //UIAlertControllerのスタイルがalert
            let alert: UIAlertController = UIAlertController(title: "アカウントを削除してもよろしいですか？", message:  "一度削除するとデータを元に戻せません", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                Auth.auth().currentUser?.delete {  (error) in
                    // エラーが無ければ、ログイン画面へ戻る
                    if error == nil {
                        let storyboar = UIStoryboard(name: "TermsOfUse", bundle: nil)
                        let TermsOfUseViewController = storyboar.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
                        let nav = UINavigationController(rootViewController: TermsOfUseViewController)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }else{
                        print("エラー：\(String(describing: error?.localizedDescription))")
                    }
                }
            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
            })
            
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            //実際にAlertを表示する
            self.present(alert, animated: true, completion: nil)
            
            
        })
        
        // 閉じるボタンが押された時の処理をクロージャ実装する
        //UIAlertActionのスタイルがCancelなので赤く表示される
        let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            //実際の処理
            print("閉じる")
        })
        
        //UIAlertControllerにタイトル1ボタンとタイトル2ボタンと閉じるボタンをActionを追加
        actionSheet.addAction(actionHowToUse)
        actionSheet.addAction(actionInquiry)
        actionSheet.addAction(actionTermsOfUse)
        actionSheet.addAction(actionReset)
        actionSheet.addAction(close)
        // iPad の場合のみ、ActionSheetを表示するための必要な設定
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,y: screenSize.size.height,width: 0,height: 0)
        }
        //実際にAlertを表示する
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // 起動時メッセージ
    @IBOutlet weak var messageLabel: UILabel!
    private func fetchedefoltMessage() {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = NSLocale.system
        let realTime = formatter.string(from: Date())
        print("realtime",realTime)
        
        if("05:01" <= realTime && realTime <= "09:59" ){
            let Message: [String] =  ["おはようございます。\nあなたにとって素敵な1日になりますように。","今日はあなたに良いことが起こりそうな気がします"]
            if let randomMessage = Message.randomElement() {
                messageLabel.text = randomMessage
            }
        }else if("10:00" <= realTime && realTime <= "17:00"){
            let Message: [String] = ["疲れた時には一息入れましょう","たまには休憩も必要ですよ","たまにはぼっ〜とすることも大切です"]
            if let randomMessage = Message.randomElement() {
                messageLabel.text = randomMessage
            }
            
        }else if("17:01" <= realTime && realTime <= "21:00"){
            
            let Message: [String] = ["今日も1日お疲れ様です。\nゆっくり休んでくださいね。","1日お疲れ様です。\n今日どんな良いことがありましたか？"]
            
            if let randomMessage = Message.randomElement() {
                messageLabel.text = randomMessage
            }
        }else if("21:01" <= realTime && realTime <= "23:59"){
            let Message: [String] = ["明日が良い日でありますように。","1日お疲れ様です。\nあなたの存在が大きな力になっていますよ","今日も1日お疲れ様です。\nおやすみなさい。","今日も1日お疲れ様です。\n今日どんな良いことがありましたか？"]
            
            if let randomMessage = Message.randomElement() {
                messageLabel.text = randomMessage
            }
            
        }else if("00:00" <= realTime && realTime <= "05:00"){
            let Message: [String] = ["1日お疲れ様です。\nおやすみなさい。","1日お疲れ様です。\nあなたの存在が大きな力になっていますよ"]
            
            if let randomMessage = Message.randomElement() {
                messageLabel.text = randomMessage
            }
            
        }
        
    }
    
    // 小鳥の一言ボタン押下時処理
    private func fetcheMessage() {
        let birdMessage: [String] =  ["神経系の疲労回復には緑茶がおすすめです。",
                                      "熟睡のため、就寝前3〜4時間以内のカフェインの摂取は控えましょう。",
                                      "安眠するために寝る前の食事、アルコールは控えましょう。","鼻呼吸が良い眠りを導きます。",
                                      "心の疲れを感じたら、自分の全てを肯定してあげましょう。","汗を流した後は心の疲労感が軽くなりますよ。","ヘッドスパやマッサージは自律神経を整え、心の疲労も取り除きます。","乳製品やハチミツ、バナナは安眠のためのおすすめ食材です。","時には自分1人になってゆっくりと過ごすことも大切です。","花は香り、色の持つパワーで人を癒す力があります。","良い睡眠をとるために、入浴で体を温めリラックスさせましょう。","糖質、脂質、タンパク質に加え、ミネラルやビタミン類もしっかり摂りましょう。","鶏むね肉は抗酸化作用に優れ、疲労回復におすすめです。","夏バテには豚肉の摂取が効果的です。","ハイカカオチョコレートは疲労回復に即効性があります。","アーモンドにはトレーニング後の疲労や筋肉痛、筋力回復の効果があります。","午後4時以降にコーヒーを飲むと眠りを妨げるためできるだけ摂取を控えましょう。","紅茶にはリラックス効果があり、緊張や不安感の解消に役立ちます。","心の疲れを溜めないためには何事も自分で抱え込まず、人にサポートを求めましょう。","家族サービスのためでなく、自分のために有給を活用することも大切です。","優先事項が複数あるとストレスで心が疲弊してしまいます。取捨選択することも大切ですよ。",
                                      "心の疲れを溜めないためにも、手軽なリフレッシュ方法を日々の生活に取り入れましょう。","「止まりさえしなければ、どんなにゆっくりでも進めばよい。」\n孔子","「疲れちょると思案がどうしても滅入る。よう寝足ると猛然と自信がわく。」\n坂本龍馬","「快い眠りこそ、自然が人間に与えてくれたやさしい、なつかしい看護婦である。」\nシェイクスピア","「幸福は人生の意味および目標、\n人間存在の究極の目的であり狙いである。」\nアリストテレス ","「人生は胸おどるものです。そしてもっともワクワクするのは、人のために生きるときです。」\nヘレン・ケラー","「待っているだけの人達にも、何かが起こるかもしれないがそれは努力をした人達の残り物だけである。」\nエイブラハム・リンカーン","「簡単すぎる人生に、\n生きる価値などない。」\nソクラテス","「心がすべてである。\nあなたはあなたの考えたとおりになる。」\nブッダ","「成功のためではなく、価値のある人間になる努力をしなさい。」\nアルベルト・アインシュタイン","「許すはよし、\n忘れるはなおよし。」\nロバート・ブラウニング","「何も後悔することがなければ、\n人生はとても空虚なものになるだろう。」\nゴッホ","「よい記憶力はすばらしいが、忘れる能力はいっそう偉大である。」\nエルバート・ハバード","「覚えていて悲しんでいるよりも、忘れて微笑んでいるほうがいい。」\nクリスティナ・ロセッティ","「何かをするためのもっとも効果的な方法は、ただやってみること。」\nアメリア・イアハート","「お前の道をすすめ。\n人には勝手な事を言わせておけ。」\nダンテ・アリギエーリ","「成功への第一歩は、どんな職業であろうとも、その仕事に興味を持つことである。」\nウィルアム・オスラー","「苦しみを恐れる者は、その恐怖だけですでに苦しんでいる。」\nモンテーニュ","「呑気と見える人々も、\n心の底を叩いて見ると、どこか悲しい音がする。」\n夏目漱石","「過ちを非難しすぎるよりも、過ちを許しすぎる方がずっといい。」\nジョージ・エリオット","「どんなことにも教訓はある。\n君がそれを見つけられるかどうかさ。」\nルイス・キャロル","「どっちへ行きたいか分からなければ、どっちの道へ行ったって大した違いはないさ。」\nルイス・キャロル","「成長の最大の源は選択にある。」\nジョージ・エリオット","「寛容であることは、広い視野を持っている人々の義務である。」\nジョージ・エリオット","「医の基本は予防にある。」\n北里柴三郎"]
        
        if let randomMessage = birdMessage.randomElement() {
            messageLabel.text = randomMessage
        }
        
    }
    
}

// 画面設定
extension UIView {
    func addBackground(name: String) {
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



