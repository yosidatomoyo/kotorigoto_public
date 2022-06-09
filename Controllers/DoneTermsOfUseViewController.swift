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

class DoneTermsOfUseViewController: UIViewController {
    
    private let DoneTermsOfUseViewControllerId = "DoneTermsOfUseViewControllerId"
        @IBOutlet weak var DoneTermsOfUseTableView: UITableView!
    
        override func viewDidLoad() {
        super.viewDidLoad()
    
        setupViews()
        DoneTermsOfUseTableView.delegate = self
        DoneTermsOfUseTableView.dataSource = self
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
    
    // 同意するボタン押下時
    @objc private func tappedagreeButton() {
        self.dismiss(animated: true, completion: nil)
     }
    }


extension DoneTermsOfUseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DoneTermsOfUseTableView.dequeueReusableCell(withIdentifier: DoneTermsOfUseViewControllerId, for: indexPath) as! DoneTermsOfUseViewControllerCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    DoneTermsOfUseTableView.estimatedRowHeight = 120
    return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

class DoneTermsOfUseViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var TermsOfUseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
