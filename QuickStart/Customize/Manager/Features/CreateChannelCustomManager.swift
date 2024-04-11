//
//  CreateChannelCustomManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class CreateChannelCustomManager: BaseCustomManager {
    static var shared = CreateChannelCustomManager()
    
    func startSample(naviVC: UINavigationController, type: CreateChannelCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .customCell:
            cellCustom()
        case .userList:
            userListCustom()
        default:
            break
        }
    }
}


extension CreateChannelCustomManager {
    func uiComponentCustom() {
        let createChannelVC = SBUCreateChannelViewController()
        
        // This part changes the default titleView to a custom view.
        createChannelVC.headerComponent?.titleView = self.createHighlightedTitleLabel()
        
        // This part changes the default leftBarButton to a custom leftBarButton.
        // RightButton can also be changed in this way.
        createChannelVC.headerComponent?.leftBarButton = self.createHighlightedBackButton()
        
        // Move to CreateChannelViewController using customized components
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }
    
    func cellCustom() {
        let createChannelVC = CreateChannelVC_Cell()
        
        // This part changes the default user cell to a custom cell.
        createChannelVC.listComponent?.register(userCell: CustomUserCell())
        
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }
    
    func userListCustom() {
        // Sendbird provides various access control options when using the Chat SDK. By default, the Allow retrieving user list attribute is turned on to facilitate creating sample apps. However, this may grant access to unwanted data or operations, leading to potential security concerns. To manage your access control settings, you can turn on or off each setting on Sendbird Dashboard.
        let params = ApplicationUserListQueryParams()
        params.limit = 20
        let userListQuery = SendbirdChat.createApplicationUserListQuery(params: params)
        userListQuery.loadNextPage { users, error in
            guard error == nil else {
                SBULog.error(error?.localizedDescription)
                return
            }
            
            // This is a user list object used for testing.
            guard let users = users?.sbu_convertUserList() else { return }
            
            // If you use a list of users who have internally generated relationship data, you can use it as follows:
            // When you're actually using it, include a list of users you're managing directly here.
            let createChannelVC = CreateChannelVC_UserList(users: users)
            
            // Push ViewController after calling the dummy user list.
            createChannelVC.loadDummyUsers {
                self.navigationController?.pushViewController(createChannelVC, animated: true)
            }
        }
    }
}
