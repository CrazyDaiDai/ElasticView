//
//  ViewController.swift
//  弹性动画
//
//  Created by 呆仔～林枫 on 2018/7/10.
//  Copyright © 2018年 最怕追求不凡,最后依然碌碌无为 - Crazy_Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cButton)
    }

    @objc func btnAction(sender: UIButton) {
        print("按钮点击点击点击")
        sender.elasticView.startUpdateLoop()
    }
    
    
    lazy var cButton: UIButton = {
        let btn = UIButton()
        btn.clipsToBounds = false
        btn.backgroundColor = UIColor.red
        btn.frame = CGRect(x: 100, y: 200, width: 150, height: 100)
        btn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        return btn
    }()

}



