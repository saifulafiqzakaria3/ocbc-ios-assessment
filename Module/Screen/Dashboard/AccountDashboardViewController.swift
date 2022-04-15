//
//  AccountDashboardViewController.swift
//  ocbc-ios-assessment
//
//  Created by HEXA-Saiful.Afiq on 11/04/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AccountDashboardViewController: UIViewController {
    
    var viewModel: AccountDashboardViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var accountInfoCardView: UIView!
    @IBOutlet weak var accountCardBackgroundImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var accountNoLabel: UILabel!
    @IBOutlet weak var accountHolderUsernameLabel: UILabel!
    
    @IBOutlet weak var transactionHistoryTableView: UITableView!
    @IBOutlet weak var transferButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.setHidesBackButton(true, animated: animated)
        setupNavigationBarButton()
        setupDisplay()
        setupTransactionHistoryTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        transformInput()
        viewModel.transform()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for:.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func transformInput() {
        viewModel.startLoad = self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).asDriver(onErrorRecover: { _ in
            return Driver.empty()
        }).map { _ in () }
        viewModel.makeTransferButtonTapped = transferButton.rx.tap.asDriver()
    }
}

//UI Handler
extension AccountDashboardViewController {
    func setupDisplay() {
        accountInfoCardView.layer.cornerRadius = 10.0
        accountInfoCardView.layer.shadowColor = CGColor(red: 118/255, green: 118/255, blue: 118/255, alpha: 1)
        accountInfoCardView.layer.shadowOffset = .zero
        accountInfoCardView.layer.shadowRadius = 5
        accountInfoCardView.layer.shadowOpacity = 1
        accountInfoCardView.layer.masksToBounds = false
        accountInfoCardView.layer.borderWidth = 1
        
        accountCardBackgroundImageView.layer.cornerRadius = 10.0
        
        transferButton.layer.cornerRadius = 8.0
        //transferButton.layer.borderWidth = 1
        
        let username = UserDefaults.standard.string(forKey: "username") ?? "No Name"
        accountHolderUsernameLabel.text = username
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Welcome \(username)!";
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    func setupNavigationBarButton() {
        //remove navbar border line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        //set navbar log put button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutUser))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.yellow
        
        if #available(iOS 15, *) {
            let ocbcRed: UIColor = UIColor(red: 239/255, green: 34/255, blue: 28/255, alpha: 1)
            // Navigation Bar background color
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ocbcRed
            
            // setup title font color
            let titleAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: ocbcRed]
            appearance.titleTextAttributes = titleAttribute
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    @objc func logoutUser(){
        self.navigationController?.popViewController(animated: true)
        UserDefaults.standard.removeObject(forKey: "appToken")
        UserDefaults.standard.removeObject(forKey: "username")
    }
    
    func setupTransactionHistoryTable() {
        transactionHistoryTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Date, Transaction>>(
            configureCell: { (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "TransactionTableViewCell")! as! TransactionTableViewCell
                cell.setupTransactionCell(transaction: element)
                return cell
                
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model.convertDateToString(to: "MMM d, yyyy")
            }
            
        )
        
        transactionHistoryTableView.rx.itemSelected.subscribe(onNext: { [weak self] indexpath in
            self?.transactionHistoryTableView.deselectRow(at: indexpath, animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.transactionSectionModel
            .bind(to: transactionHistoryTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension AccountDashboardViewController: DashboardProtocol {
    func updateBalanceInfo(balanceInfo: Balance) {
        let doubleStr = String(format: "%.2f", balanceInfo.balance ?? 0)
        balanceLabel.text = "SGD " + doubleStr
        accountNoLabel.text = balanceInfo.accountNo ?? "N/A"
    }
    
    func routeToTransfer() {
        //        guard let transactionDashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "TransferViewController") else { return }
        //        self.navigationController?.pushViewController(transactionDashboardVC, animated: true)
    }
}
