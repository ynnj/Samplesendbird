//  MainChannelTabbarController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

enum TabType {
    case channels, mySettings, subscription, login
}


class MainChannelTabbarController: UITabBarController {
//    FEED / CHAT / SUBSCRIPTIONS / SETTINGS
    let channelsViewController = ChannelListViewController()
    let subscriptionViewController = SBUCreateChannelViewController()
    let settingsViewController = MySettingsViewController()
    let loginViewController = LoginViewController()
    
    var channelsNavigationController = UINavigationController()
    var subscriptionNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    var loginNavigationController = UINavigationController()

    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsViewController.headerComponent?.titleView = UIView()
        channelsViewController.headerComponent?.leftBarButton = self.createLeftTitleItem(text: "Chats")
        
        self.channelsNavigationController = UINavigationController(
            rootViewController: channelsViewController
        )
        
        self.subscriptionNavigationController = UINavigationController(
            rootViewController: subscriptionViewController
        )
        
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        self.loginNavigationController = UINavigationController(
            rootViewController: loginViewController
        )
        

        
        let tabbarItems = [
            self.channelsNavigationController,
            self.subscriptionNavigationController,
            self.mySettingsNavigationController,
            self.loginNavigationController
        ]
        self.viewControllers = tabbarItems
        self.setupStyles()
        
        SendbirdChat.addUserEventDelegate(self, identifier: self.sbu_className)
        
        self.loadTotalUnreadMessageCount()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        SendbirdChat.removeUserEventDelegate(forIdentifier: self.sbu_className)
    }
    
    public func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
//        testViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
//            text: "Feed"
//        )
//        testViewController.tabBarItem = self.createTabItem(type: .test)
        channelsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Chats"
        )
        channelsViewController.tabBarItem = self.createTabItem(type: .channels)
        
        
        subscriptionViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Discover"
        )
        subscriptionViewController.tabBarItem = self.createTabItem(type: .subscription)
        
        settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Settings"
        )
        settingsViewController.tabBarItem = self.createTabItem(type: .mySettings)
        
        loginViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Login"
        )
        loginViewController.tabBarItem = self.createTabItem(type: .login)
        

        self.channelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.subscriptionNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.loginNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
    }

    // MARK: - SDK related
    func loadTotalUnreadMessageCount() {
        SendbirdChat.getTotalUnreadMessageCount { (totalCount, error) in
            self.setUnreadMessagesCount(totalCount)
        }
    }

    // MARK: - Create items
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = theme.titleColor
        return UIBarButtonItem.init(customView: titleLabel)
    }

    func createTabItem(type: TabType) -> UITabBarItem {
        let iconSize = CGSize(width: 24, height: 24)
        let title: String
        let icon: UIImage?
        let tag: Int

        switch type {
        case .channels:
            title = "Chats"
            icon = UIImage(named: "iconChatFilled")?.resize(with: iconSize)
            tag = 1
        case .subscription:
            title = "Subscription"
            icon = UIImage(named: "iconStreaming")?.resize(with: iconSize)
            tag = 4
        case .mySettings:
            title = "Settings"
            icon = UIImage(named: "iconSettingsFilled")?.resize(with: iconSize)
            tag = 3
        case .login:
            title = "Login"
            icon = UIImage(named: "iconSettingsFilled")?.resize(with: iconSize)
            tag = 2
        }

        let item = UITabBarItem(title: title, image: icon, tag: tag)
        return item
    }

    // MARK: - Common
    func setUnreadMessagesCount(_ totalCount: UInt) {
        var badgeValue: String?
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
        self.channelsViewController.tabBarItem.badgeColor = SBUColorSet.error300
        self.channelsViewController.tabBarItem.badgeValue = badgeValue
        self.channelsViewController.tabBarItem.setBadgeTextAttributes(
            [
                NSAttributedString.Key.foregroundColor : isDarkMode
                    ? SBUColorSet.onlight01
                    : SBUColorSet.ondark01,
                NSAttributedString.Key.font : SBUFontSet.caption4
            ],
            for: .normal
        )
    }
    
    func updateTheme(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        
        self.setupStyles()
        self.channelsViewController.setupStyles()
        self.settingsViewController.setupStyles()

        self.channelsViewController.listComponent?.reloadTableView()
        
        self.loadTotalUnreadMessageCount()
    }
}

extension MainChannelTabbarController: UserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : Int]?) {
        self.setUnreadMessagesCount(UInt(totalCount))
    }
}
