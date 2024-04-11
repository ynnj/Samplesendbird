//  MainChannelTabbarController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

enum TabType {
    case channels, mySettings, subscription
}


class MainChannelTabbarController: UITabBarController {
//    FEED / CHAT / SUBSCRIPTIONS / SETTINGS
    let channelsViewController = ChannelListViewController()
    let subscriptionViewController = SBUCreateChannelViewController()
    let settingsViewController = MySettingsViewController()
    
    var channelsNavigationController = UINavigationController()
    var subscriptionNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()

//    TEST IF GIT CONTROL IS WORKING FOR ANY CHANGES
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
        

        
        let tabbarItems = [
            self.channelsNavigationController,
            self.subscriptionNavigationController,
            self.mySettingsNavigationController
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
//        self.tabBar.barTintColor = #colorLiteral(red: 0.3960784314, green: 0.7725490196, blue: 0.6352941176, alpha: 1)
//        self.tabBar.tintColor = .black
    

//        self.tabBar.barTintColor = self.isDarkMode
//            ? SBUColorSet.background600
//            : .white
//        self.tabBar.tintColor = self.isDarkMode
//            ? SBUColorSet.primary200
//            : SBUColorSet.primary300
//        
//        
        
        
//        testViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
//            text: "Feed"
//        )
//        testViewController.tabBarItem = self.createTabItem(type: .test)
        channelsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Chats"
        )
        settingsViewController.tabBarItem = self.createTabItem(type: .mySettings)
        subscriptionViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Discover"
        )
        channelsViewController.tabBarItem = self.createTabItem(type: .channels)
        settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Settings"
        )
        subscriptionViewController.tabBarItem = self.createTabItem(type: .subscription)

        self.channelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.subscriptionNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
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
