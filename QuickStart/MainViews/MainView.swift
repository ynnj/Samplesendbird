//
//  MainView.swift
//  QuickStart
//
//  Created by Damon Park on 2023/08/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class MainView: NibCustomView {
    @IBOutlet weak var homeStackView: UIStackView! {
        willSet {
            newValue.alpha = 0
        }
    }
    
    @IBOutlet weak var groupChannelItemView: MainItemView! {
        willSet {
            newValue.titleLabel.text = "Group channel"
            newValue.descriptionLabel.text = "1 on 1, Group chat with members"
        }
    }
    
//    @IBOutlet weak var openChannelItemView: MainItemView! {
//        willSet {
//            newValue.titleLabel.text = "Open channel"
//            newValue.descriptionLabel.text = "Live streams, Open community chat"
//            newValue.unreadCountLabel.isHidden = true
//        }
//    }
    
    @IBOutlet weak var signOutButton: UIButton! {
        willSet {
            let signOutColor = UIColor.black.withAlphaComponent(0.88)
            newValue.layer.cornerRadius = ViewController.CornerRadius.small.rawValue
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = signOutColor.cgColor
            newValue.setTitleColor(signOutColor, for: .normal)
        }
    }
}
