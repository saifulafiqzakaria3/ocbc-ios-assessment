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
        viewModel = AccountDashboardViewModel()
        viewModel.view = self
        transformInput()
        viewModel.transform()
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
        accountInfoCardView.layer.shadowOpacity = 0.2
        accountInfoCardView.layer.masksToBounds = false
        
        transferButton.layer.cornerRadius = 8.0
        transferButton.layer.borderWidth = 1
        
        let username = UserDefaults.standard.string(forKey: "username")
        accountHolderUsernameLabel.text = username ?? "N/A"
    }
    
    func setupNavigationBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutUser))
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
        guard let transactionDashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "TransferViewController") else { return }
        self.navigationController?.pushViewController(transactionDashboardVC, animated: true)
    }
}
