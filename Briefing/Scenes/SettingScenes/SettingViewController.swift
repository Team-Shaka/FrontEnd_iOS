//
//  SettingViewController.swift
//  Briefing
//
//  Created by 이전희 on 2023/10/05.
//

import UIKit

enum SettingTableViewCellType {
    case `default`(symbol: UIImage, title: String, type: SettingTableViewDefaultCellType)
    case auth(title: String, color: UIColor = .briefingBlue, type: SettingTableViewAuthCellType)
}

enum SettingTableViewDefaultCellType {
    case text(_ text: String)
    case url(_ urlString: String)
    case customView(_ view: UIView)
}

enum SettingTableViewAuthCellType {
    case signInAndRegister
    case signOut
    case withdrawal
}

class SettingViewController: UIViewController {
    private let authManager = BriefingAuthManager.shared
    
    @UserDefaultWrapper(key: .notificationTime, defaultValue: nil)
    var notificationTime: NotificationTime?
    
    private lazy var settingCellData: [[SettingTableViewCellType]] = [
        [
            .default(symbol: BriefingImageCollection.Setting.clock,
                     title: BriefingStringCollection.Setting.notificationTimeSetting.localized,
                     type: .customView(self.notificationTimePickerButton))
        ],
        [
            .default(symbol: BriefingImageCollection.Setting.appVersion,
                     title: BriefingStringCollection.Setting.appVersionTitle.localized,
                     type: .text(BriefingStringCollection.appVersion)),
            .default(symbol: BriefingImageCollection.Setting.feedback,
                     title: BriefingStringCollection.Setting.feedbackAndInquiry.localized,
                     type: .url(BriefingStringCollection.Link.feedBack.localized)),
            .default(symbol: BriefingImageCollection.Setting.versionNote,
                     title: BriefingStringCollection.Setting.versionNote.localized,
                     type: .url(BriefingStringCollection.Link.versionNote.localized))
        ],
        [
            .default(symbol: BriefingImageCollection.Setting.termsOfService,
                     title: BriefingStringCollection.Setting.termsOfService.localized,
                     type: .url(BriefingStringCollection.Link.termsOfService.localized)),
            .default(symbol: BriefingImageCollection.Setting.privacyPolicy,
                     title: BriefingStringCollection.Setting.privacyPolicy.localized,
                     type: .url(BriefingStringCollection.Link.privacyPolicy.localized)),
            .default(symbol: BriefingImageCollection.Setting.caution,
                     title: BriefingStringCollection.Setting.caution.localized,
                     type: .url(BriefingStringCollection.Link.caution.localized))
        ],
        []
    ]
    
    private let authCellSectionInsertIndex: Int = 3
    private var authCellSectionData: [SettingTableViewCellType] {
        if authManager.member != nil {
            return [
                .auth(title: BriefingStringCollection.Setting.signOut.localized,
                      type: .signOut),
                .auth(title: BriefingStringCollection.Setting.withdrawal.localized,
                      color: .briefingRed,
                      type: .withdrawal)
            ]
        } else {
            return [
                .auth(title: BriefingStringCollection.Setting.signInAndRegister.localized,
                      type: .signInAndRegister)
            ]
        }
    }
    
    private var navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(BriefingImageCollection.backIconImage, for: .normal)
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(goBackToHomeViewController), for: .touchUpInside)
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = BriefingStringCollection.Setting.settings.localized
        label.font = .productSans(size: 24)
        label.textColor = .briefingNavy
        return label
    }()
    
    private var settingTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = 50
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = 52
        return tableView
    }()
    
    private var notificationTimePickerButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .briefingLightBlue.withAlphaComponent(0.4)
        let button = UIButton(configuration: configuration)
        button.setTitle("_", for: .normal)
        button.setTitleColor(.briefingNavy, for: .normal)
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        settingTableView.reloadSections(IndexSet(integer: authCellSectionInsertIndex),
                                        with: .fade)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
    }
    
    private func configure() {
        self.view.backgroundColor = .briefingWhite
        
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
        self.settingTableView.register(SettingTableViewDefaultCell.self,
                                       forCellReuseIdentifier: SettingTableViewDefaultCell.identifier)
        self.settingTableView.register(SettingTableViewAuthCell.self,
                                       forCellReuseIdentifier: SettingTableViewAuthCell.identifier)
        
        self.notificationTimePickerButton.addTarget(self, action: #selector(showTimePickerView(_:)), for: .touchUpInside)
        let notificationTime = self.notificationTime?.toString() ?? BriefingStringCollection.Setting.setting.localized
        self.notificationTimePickerButton.setTitle(notificationTime, for: .normal)
        addSwipeGestureToDismiss()
    }
    
    private func addSubviews() {
        [backButton, titleLabel].forEach { subView in
            navigationView.addSubview(subView)
        }
        
        [navigationView, settingTableView].forEach { subView in
            view.addSubview(subView)
        }
    }
    
    private func makeConstraints() {
        navigationView.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(titleLabel).offset(25)
            make.leading.trailing.equalTo(view)
        }
        
        backButton.snp.makeConstraints{ make in
            make.centerY.equalTo(navigationView)
            make.height.equalTo(titleLabel)
            make.width.equalTo(backButton.snp.height)
            make.leading.equalTo(navigationView).inset(21)
        }
        
        titleLabel.snp.makeConstraints{ make in
            make.centerY.equalTo(navigationView)
            make.centerX.equalTo(navigationView)
        }
        
        settingTableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func selectSignInAndRegister() {
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    func selectSignOut() {
        let title = BriefingStringCollection.Setting.signOut.localized
        let description = BriefingStringCollection.Setting.signOutDescription.localized
        let cancel = BriefingStringCollection.cancel
        let popupViewController = BriefingPopUpViewController(index: 0,
                                                              title: title,
                                                              description: description,
                                                              buttonTitles:[cancel, title],
                                                              style: .twoButtonsDestructive)
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.delegate = self
        self.present(popupViewController, animated: false)
    }
    
    func selectWithdrawal() {
        let title = BriefingStringCollection.Setting.withdrawal.localized
        let description = BriefingStringCollection.Setting.withdrawalDescription.localized
        let cancel = BriefingStringCollection.cancel
        let popupViewController = BriefingPopUpViewController(index: 1,
                                                              title: title,
                                                              description: description,
                                                              buttonTitles:[cancel, title],
                                                              style: .twoButtonsDestructive)
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.delegate = self
        self.present(popupViewController, animated: false)
    }

    func showErrorMessage(message: String) {
        let title = BriefingStringCollection.Setting.withdrawal.localized
        let confirm = BriefingStringCollection.confirm
        let popupViewController = BriefingPopUpViewController(index: 1,
                                                              title: title,
                                                              description: message,
                                                              buttonTitles:[confirm],
                                                              style: .normal)
        popupViewController.modalPresentationStyle = .overFullScreen
        popupViewController.delegate = self
        self.present(popupViewController, animated: false)
    }
    
    @objc func goBackToHomeViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingCellData.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var settingCellData = settingCellData
        settingCellData.insert(authCellSectionData,
                               at: authCellSectionInsertIndex)
        return settingCellData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var settingCellData = settingCellData
        settingCellData.insert(authCellSectionData,
                               at: authCellSectionInsertIndex)
        let cellSectionData = settingCellData[indexPath.section]
        
        var cornerMaskEdge: UIRectEdge? = nil
        if indexPath.row == (cellSectionData.count - 1) { cornerMaskEdge = .bottom }
        if indexPath.row == 0 { cornerMaskEdge = cornerMaskEdge == .bottom ? .all : .top }
        
        switch cellSectionData[indexPath.row] {
        case let .default(symbol, title, type):
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: SettingTableViewDefaultCell.identifier) as? SettingTableViewDefaultCell else {
                return UITableViewCell()
            }
            cell.setCellData(symbol: symbol,
                             title: title,
                             type: type,
                             cornerMaskEdge: cornerMaskEdge)
            return cell
        case let .auth(title, color, _):
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: SettingTableViewAuthCell.identifier) as? SettingTableViewAuthCell else {
                return UITableViewCell()
            }
            cell.setCellData(title: title,
                             color: color,
                             cornerMaskEdge: cornerMaskEdge)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var settingCellData = settingCellData
        settingCellData.insert(authCellSectionData,
                               at: authCellSectionInsertIndex)
        let cellSectionData = settingCellData[indexPath.section]
        
        switch  cellSectionData[indexPath.row] {
        case let .default(_, _, type):
            switch type {
            case let .url(urlString):
                self.openURLInSafari(urlString)
            default: break
            }
        case let .auth(_, _, type):
            switch type {
            case .signInAndRegister: selectSignInAndRegister()
            case .signOut: selectSignOut()
            case .withdrawal: selectWithdrawal()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    @objc func showTimePickerView(_ sender: UIButton) {
        let viewController = SettingTimePickerViewController()
        viewController.delegate = self
        self.present(viewController, animated: true)
    }
}

extension SettingViewController: SettingTimePickerViewControllerDelegate {
    func setTime(_ time: NotificationTime) {
        self.notificationTime = time
        let notificationTime = self.notificationTime?.toString() ?? BriefingStringCollection.Setting.setting.localized
        self.notificationTimePickerButton.setTitle(notificationTime, for: .normal)
    }
    
    func removeTime() {
        self.notificationTime = nil
        let notificationTime = self.notificationTime?.toString() ?? BriefingStringCollection.Setting.setting.localized
        self.notificationTimePickerButton.setTitle(notificationTime, for: .normal)
    }
}

extension SettingViewController: BriefingPopUpDelegate {
    func cancelButtonTapped(_ popupViewController: BriefingPopUpViewController) { }
    
    func confirmButtonTapped(_ popupViewController: BriefingPopUpViewController) {
        switch popupViewController.index {
        case 0:
            authManager.signOut()
            settingTableView.reloadSections(IndexSet(integer: authCellSectionInsertIndex),
                                            with: .fade)
        case 1:
            authManager.withdrawal { [weak self] result, error in
                if let error = error as? BFNetworkError {
                    switch error {
                    case let .requestFail(_, message):
                        self?.showErrorMessage(message: message)
                        return
                    default: break
                    }
                }
                
                self?.settingTableView.reloadSections(IndexSet(integer: self?.authCellSectionInsertIndex ?? 3),
                                                     with: .fade)
            }
            break
        default: break
        }
    }
}
