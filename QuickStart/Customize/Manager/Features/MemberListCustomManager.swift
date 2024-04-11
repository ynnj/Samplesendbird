//
//  MemberListCustomManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class MemberListCustomManager: BaseCustomManager {
    static var shared = MemberListCustomManager()
    
    func startSample(naviVC: UINavigationController, type: MemberListCustomType?) {
        self.navigationController = naviVC
        
        switch type {
        case .uiComponent:
            uiComponentCustom()
        case .customCell:
            cellCustom()
        case .functionOverriding:
            functionOverridingCustom()
        default:
            break
        }
    }
}


extension MemberListCustomManager {
    func uiComponentCustom() {
        ChannelManager.getSampleChannel { channel in
            let memberListVC = SBUUserListViewController(channel: channel)
            
            // This part changes the default titleView to a custom view.
            memberListVC.headerComponent?.titleView = self.createHighlightedTitleLabel()
            
            // This part changes the default leftBarButton to a custom leftBarButton.
            // RightButton can also be changed in this way.
            memberListVC.headerComponent?.leftBarButton = self.createHighlightedBackButton()
            
            // Move to MemberListViewController using customized components
            self.navigationController?.pushViewController(memberListVC, animated: true)
        }
    }
    
    func cellCustom() {
        ChannelManager.getSampleChannel { channel in
            let memberListVC = SBUUserListViewController(channel: channel)
            memberListVC.listComponent = MemberListModule_List_CustomCell()
            
            self.navigationController?.pushViewController(memberListVC, animated: true)
        }
    }
    
    func functionOverridingCustom() {
        ChannelManager.getSampleChannel { channel in
            // If you inherit `SBUMemberListViewController`, you can customize it by overriding some functions.
            let memberListVC = MemberListVC_Overriding(channel: channel)
            
            self.navigationController?.pushViewController(memberListVC, animated: true)
        }
    }
}
