//
//  TermsOfUseViewController.swift
//  ChatAppWithFirebase
//
//  Created by 吉田知代 on 2021/04/20.
//  Copyright © 2021 吉田　知代. All rights reserved.
//

import UIKit
import Firebase
import Nuke
import SnapKit

class TermsOfUseViewController: UIViewController {
    
    private let TermsOfUseViewControllerId = "TermsOfUseViewControllerId"
    @IBOutlet weak var TermsOfUseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        TermsOfUseTableView.delegate = self
        TermsOfUseTableView.dataSource = self
        navigationItem.title = "利用規約"
        
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.foregroundColor: UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)]
    }
    
    // 同意するボタン押下時処理
    private func setupViews() {
        let agreeButton = UIBarButtonItem(title: "同意する", style: .plain, target: self, action: #selector(tappedagreeButton))
        
        navigationItem.rightBarButtonItem = agreeButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)
        
    }
    
    @objc private func tappedagreeButton() {
        conform()
    }
    
    // 確認アラート表示
    private func conform(){
        //アラート生成
        //UIAlertControllerのスタイルがalert
        let alert: UIAlertController = UIAlertController(title: "年齢は18歳以上ですか？", message:  "", preferredStyle:  UIAlertController.Style.alert)
        // 確定ボタンの処理
        let confirmAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // 確定ボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
            //実際の処理
            let storyboar = UIStoryboard(name: "HowToUse1", bundle: nil)
            let HowToUsefirstController = storyboar.instantiateViewController(withIdentifier: "HowToUsefirstController") as! HowToUsefirstController
            let nav = UINavigationController(rootViewController: HowToUsefirstController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        })
        // キャンセルボタンの処理
        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            // キャンセルボタンが押された時の処理をクロージャ実装する
            (action: UIAlertAction!) -> Void in
        })
        
        // UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        // 実際にAlertを表示する
        present(alert, animated: true, completion: nil)
        
    }
    
}
extension TermsOfUseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TermsOfUseTableView.dequeueReusableCell(withIdentifier: TermsOfUseViewControllerId, for: indexPath) as! TermsOfUseViewControllerCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        TermsOfUseTableView.estimatedRowHeight = 120
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

class TermsOfUseViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var TermsOfUseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
