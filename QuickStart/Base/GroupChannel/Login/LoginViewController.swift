//
//  MySettingsViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
import MobileCoreServices
import StoreKit
import SwiftUI


open class LoginViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate: MySettingsDelegate?
    weak var mainViewController: ViewController?
    let viewModel = AuthenticationViewModel()

    
    // MARK: - Properties
    lazy var rightBarButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Edit,
            style: .plain,
            target: self,
            action: #selector(onClickEdit)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    lazy var userInfoView = UserInfoTitleView()
    lazy var tableView = UITableView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    var isDoNotDisturbOn: Bool = false
    
    
    // MARK: - Constant
    private let actionSheetIdEdit = 1
    private let actionSheetIdPicker = 2
    
    // MARK: - Life cycle
    open override func loadView() {
        super.loadView()
        
        // navigation bar
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        // tableView
        //        self.tableView.delegate = self
        //        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorColor =  UIColor.clear
        
        self.tableView.register(
            type(of: MySettingsCell()),
            forCellReuseIdentifier: MySettingsCell.sbu_className
        )
        self.tableView.tableHeaderView = self.userInfoView
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        // autolayout
        self.setupLayouts()
        
        // styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() {
        self.userInfoView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        layoutConstraints.append(self.userInfoView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.userInfoView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: 0)
        )
        
        layoutConstraints.append(self.tableView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.tableView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: 0)
        )
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        self.navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: theme.navigationBarTintColor
        )
        
        self.rightBarButton.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorStyle = .none
        if let user = SBUGlobals.currentUser {
            self.userInfoView.configure(user: user)
        }
        
        self.loadDisturbSetting {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Create a UIHostingController for AuthenticatedView
         let authenticatedViewHostingController = UIHostingController(rootView: AuthenticatedView {
             UserProfileView()
         }.environmentObject(viewModel))
         
         // Set the size of the hosted view
         authenticatedViewHostingController.view.frame = view.bounds
         
         // Add the hosted view as a child view controller
         addChild(authenticatedViewHostingController)
         view.addSubview(authenticatedViewHostingController.view)
         authenticatedViewHostingController.didMove(toParent: self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tableView.separatorStyle = .none
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    @objc func loginButtonTapped() {
        // Create a HostingController for the LoginView
        let loginViewHostingController = UIHostingController(rootView: LoginView().environmentObject(viewModel))
        
        // Present the LoginView modally
        present(loginViewHostingController, animated: true, completion: nil)
    }
    
    // MARK: - SDK related
    func loadDisturbSetting(_ completionHandler: @escaping (() -> Void)) {
        SendbirdChat.getDoNotDisturb { [weak self] (isDoNotDisturbOn, _, _, _, _, _, error) in
            self?.isDoNotDisturbOn = error == nil ? isDoNotDisturbOn : false
            completionHandler()
        }
    }
    
    func changeDisturb(isOn: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        SendbirdChat.setDoNotDisturb(
            enable: isOn,
            startHour: 0,
            startMin: 0,
            endHour: 23,
            endMin: 59,
            timezone: "UTC"
        ) { error in
            guard error == nil else {
                completionHandler?(false)
                return
            }
            
            completionHandler?(true)
        }
    }
    
    
    // MARK: - Actions
    /// Open the user edit action sheet.
    @objc func onClickEdit() {
        let changeNameItem = SBUActionSheetItem(
            title: "Change my nickname",
            color: theme.itemTextColor,
            image: nil
        ) {}
        let changeImageItem = SBUActionSheetItem(
            title: "Change my profile image",
            color: theme.itemTextColor,
            image: nil
        ) {}
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor
        ) {}
        SBUActionSheet.show(
            items: [changeNameItem, changeImageItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdEdit
            //            delegate: self
        )
    }
    
    @objc func backToMain() {
        // Dismiss the current MySettingsViewController
        
        print("back to main")
        
        self.dismiss(animated: true) {
            // Instantiate ViewController or its subsequent ConnectView
            let connectViewController = ViewController() // Or the appropriate class
            let navigationController = UINavigationController(rootViewController: connectViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            // Present the ViewController or ConnectView
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
    /// Open the nickname change popup.
    public func changeNickname() {
        let okButton = SBUAlertButtonItem(title: SBUStringSet.OK) {[weak self] newNickname in
            guard let nickname = newNickname as? String,
                  nickname.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
            else { return }
            
            // Sendbird provides various access control options when using the Chat SDK. By default, the Allow retrieving user list attribute is turned on to facilitate creating sample apps. However, this may grant access to unwanted data or operations, leading to potential security concerns. To manage your access control settings, you can turn on or off each setting on Sendbird Dashboard.
            SendbirdUI.updateUserInfo(nickname: nickname, profileURL: nil) { (error) in
                guard error == nil else {
                    SBULog.error(error?.localizedDescription)
                    return
                }
                guard let user = SBUGlobals.currentUser else { return }
                UserDefaults.saveNickname(nickname)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.userInfoView.configure(user: user)
                }
            }
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        SBUAlertView.show(
            title: "Change my nickname",
            needInputField: true,
            placeHolder: "Enter nickname",
            centerYRatio: 0.75,
            confirmButtonItem: okButton,
            cancelButtonItem: cancelButton
        )
    }
    
    /// Open the user image selection menu.
    public func selectUserImage() {
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.Camera,
            image: SBUIconSet.iconCamera.sbu_with(tintColor: theme.itemColor),
            completionHandler: nil
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.PhotoVideoLibrary,
            image: SBUIconSet.iconPhoto.sbu_with(tintColor: theme.itemColor),
            completionHandler: nil
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor,
            completionHandler: nil
        )
        SBUActionSheet.show(
            items: [cameraItem, libraryItem],
            cancelItem: cancelItem,
            identifier: actionSheetIdPicker
            //            delegate: self
        )
    }
    
    
    
    func changeDisturbSwitch(isOn: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        self.changeDisturb(isOn: isOn, completionHandler)
    }
    
    
    
    
    
    
    
    // PURCHASE BUTTON LOGIC
    // Enum to represent product identifiers
    enum ProductIdentifier: String {
        case subscriptionMonthly = "subscription.monthly"
        case subscriptionYearly = "subscription.yearly"
        // Add other product cases if needed
    }
    
    
    
    // Method to initiate the in-app purchase process
    func initiatePurchase() {
        guard SKPaymentQueue.canMakePayments() else {
            // Handle case where in-app purchases are disabled
            return
        }
        
        
        // Retrieve the product identifier from your StoreKit configuration file
        guard let productIdentifier = ProductIdentifier(rawValue: "subscription.monthly") else {
            // Handle error: Product identifier not found
            return
        }
        
        // Request product information from the App Store for the given product identifier
        let productRequest = SKProductsRequest(productIdentifiers: [productIdentifier.rawValue])
        //        productRequest.delegate = self
        productRequest.start()
    }
    
    
    
    
    
    
    
    
    
}
