//
//  AccountDashboardViewController.swift
//  ocbc-ios-assessment
//
//  Created by HEXA-Saiful.Afiq on 11/04/2022.
//

import UIKit
import RxSwift
import RxCocoa

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
        setupNavigationBarButton()
        setupDisplay()
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
    }
    
    func setupNavigationBarButton() {
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutUser))
    }
    
    @objc func logoutUser(){
         print("clicked")
    }
    
    func setupTransactionHistoryTable() {
        transactionHistoryTableView.separatorStyle = .none
        
        //transactionHistoryTableView.register(UINib(nibName: "", bundle: nil), forCellReuseIdentifier: "")
        
//        let populateMovieList = viewModel.movieList.bind(to: transactionHistoryTableView.rx.items(cellIdentifier: "MovieTableViewCell")) { row, item, cell in
//            if let movieCell = cell as? MovieTableViewCell {
//                movieCell.setupCell(movie: item)
//            }
//        }
//
//        let removeSelectionHighlight =  tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexpath in
//            self?.tableView.deselectRow(at: indexpath, animated: true)
//        })
//
//
//        disposeBag.insert(
//            populateMovieList,
//            removeSelectionHighlight
//        )
    }
    
}

extension AccountDashboardViewController: DashboardProtocol {
    func updateBalanceInfo(balanceInfo: Balance) {
        let doubleStr = String(format: "%.2f", balanceInfo.balance ?? 0)
        balanceLabel.text = "SGD " + doubleStr
        accountNoLabel.text = balanceInfo.accountNo ?? "N/A"
        accountHolderUsernameLabel.text = "N/A"
    }
    
    func routeToTransfer() {
        guard let transactionDashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "TransferViewController") else { return }
        self.navigationController?.pushViewController(transactionDashboardVC, animated: true)
    }
}
