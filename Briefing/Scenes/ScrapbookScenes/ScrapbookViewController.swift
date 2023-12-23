//
//  ScrapbookViewController.swift
//  Briefing
//
//  Created by BoMin Lee on 11/2/23.
//

import UIKit
import SnapKit

class ScrapbookViewController: UIViewController {
    private let networkManager = BriefingNetworkManager.shared
    
    var scrapData: [(Date, [ScrapData])]? = []
    var isFetchedTableView: Bool = false
    
    private var navigationView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow_blue"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(goBackToHomeViewController), for: .touchUpInside)
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = BriefingStringCollection.Scrapbook.scrapbookTitle.localized
        label.font = .productSans(size: 24)
        label.textColor = .briefingNavy
        return label
    }()
    
    private var scrapTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
//        tableView.sectionHeaderHeight = 50
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = 52
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraint()
        fetchScrapbook()
    }
    
    private func configure() {
        self.view.backgroundColor = .briefingWhite
        
        self.scrapTableView.delegate = self
        self.scrapTableView.dataSource = self
        self.scrapTableView.register(ScrapbookTableViewHeaderCell.self, forCellReuseIdentifier: ScrapbookTableViewHeaderCell.identifier)
        self.scrapTableView.register(ScrapbookTableViewCell.self,
                                     forCellReuseIdentifier: ScrapbookTableViewCell.identifier)
        
        addSwipeGestureToDismiss()
    }
    
    private func addSubviews() {
        navigationView.addSubviews(backButton, titleLabel)
        
        self.view.addSubviews(navigationView, scrapTableView)
    }
    
    private func makeConstraint() {
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
        
        scrapTableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func fetchScrapbook() {
        networkManager.fetchScrapBrifings() { [weak self] value, error in
            guard let self = self else  { return }
            if let error = error {
                self.errorHandling(error)
                return
            }
            guard let scrapData = value else { return }
            self.scrapData = scrapData
            self.isFetchedTableView.toggle()
            self.scrapTableView.reloadData()
            
        }
    }
    
    private func errorHandling(_ error: Error) {
        print("error: \(error)")
    }
    
    @objc func goBackToHomeViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ScrapbookViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let scrapData = scrapData else { return 0 }
        return scrapData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let scrapRowData = scrapData?[safe: section] else { return 0 }
        return scrapRowData.1.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellSectionData = scrapData?[safe: indexPath.section]?.1 else { return UITableViewCell() }
        
        var cornerMaskEdge: UIRectEdge? = nil
        if indexPath.row == (cellSectionData.count) { cornerMaskEdge = .bottom }
        if indexPath.row == 1 { cornerMaskEdge = cornerMaskEdge == .bottom ? .all : .top }
        
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScrapbookTableViewHeaderCell.identifier) as? ScrapbookTableViewHeaderCell else {
                return UITableViewCell()
            }
            
            if let cellData = cellSectionData[safe: indexPath.row] {
                cell.setCellData(date: cellData.date, cornerMaskEdge: cornerMaskEdge)
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                        
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScrapbookTableViewCell.identifier) as? ScrapbookTableViewCell else {
                return UITableViewCell()
            }
            
            if let cellData = cellSectionData[safe: indexPath.row - 1] {
//                cell.setCellData(title: cellData.title,
//                                 subtitle: cellData.subTitle,
//                                 date: cellData.date,
//                                 cornerMaskEdge: cornerMaskEdge)
                cell.setCellData(title: cellData.title,
                                 subtitle: cellData.subTitle,
                                 date: cellData.date,
                                 time: cellData.timeOfDay,
                                 rank: cellData.ranks,
                                 gptInformation: cellData.gptModel,
                                 cornerMaskEdge: cornerMaskEdge)
            }
            
            if indexPath.row == (cellSectionData.count) { cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = self.scrapData?[safe: indexPath.section]?.1[safe: indexPath.row-1]?.briefingId else { return }
        self.navigationController?.pushViewController(BriefingCardViewController(id: id), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 60
        default:
            return 54
        }
    }
    
}
