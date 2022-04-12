//
//  AccountDashboardViewModel.swift
//  ocbc-ios-assessment
//
//  Created by HEXA-Saiful.Afiq on 11/04/2022.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

protocol DashboardProtocol {
    func routeToTransfer()
    func updateBalanceInfo(balanceInfo: Balance)
}

class AccountDashboardViewModel {
    weak var view: (UIViewController & DashboardProtocol)? = nil
    let disposeBag = DisposeBag()
    
    var startLoad: Driver<Void> = .never()
    var makeTransferButtonTapped: Driver<Void> = .never()
    let transactionList = BehaviorRelay<[Transaction]>(value: [])
    let transactionSectionModel = BehaviorRelay<[SectionModel<String, Transaction>]>(value: [])
    
    private let apiService: APIServiceProtocol
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func transform() {
        
        let getBalanceInfo = startLoad.flatMapLatest{self.apiService.getBalanceInfo()}
        let getTransactionHistory = startLoad.flatMapLatest{self.apiService.getTransactionHistory()}
        
        let updateBalanceCard = getBalanceInfo.do(onNext: { [weak self] balanceInfo in
            guard let self = self else { return }
            self.view?.updateBalanceInfo(balanceInfo: balanceInfo)
        })
        
        let updateTable = getTransactionHistory.do(onNext: { [weak self] resp in
            guard let self = self, let transactions = resp.data else { return }
            let sectionModels = self.createSectionModel(transactions: transactions)
            self.transactionSectionModel.accept(sectionModels)
        })
        
        let routeToTranferPage = makeTransferButtonTapped.do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.view?.routeToTransfer()
        })
        
        disposeBag.insert(
            updateBalanceCard.drive(),
            updateTable.drive(),
            routeToTranferPage.drive()
        )
    }
    
}

extension AccountDashboardViewModel {
    //TODO: Convert to local time
    private func convertISO8601StringToDate(isoString: String?) -> Date? {
        guard let isoString = isoString else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.date(from: isoString)
        
    }
    
    private func convertDateToString(dateToConvert: Date, to dateFormat: String = "YY/MM/dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: dateToConvert)
    }
    
    func groupTransactionsByDate(transactions: [Transaction]) -> [Date: [Transaction]]{
        let empty: [Date: [Transaction]] = [:]
        return transactions.reduce(into: empty) { acc, transaction in
            let transDate = self.convertISO8601StringToDate(isoString: transaction.transactionDate) ?? Date.now
            let components = Calendar.current.dateComponents([.day, .month, .year], from: transDate)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [transaction]
        }
    }
    
    func createSectionModel(transactions: [Transaction]) -> [SectionModel<String, Transaction>] {
        let transactionHistoryDict = self.groupTransactionsByDate(transactions: transactions)
        return transactionHistoryDict.map({(key, trans) -> SectionModel<String, Transaction> in
            let formattedDateString = self.convertDateToString(dateToConvert: key, to: "MMM d, yyyy")
            return SectionModel(model: formattedDateString, items: trans)
        })
    }
    
    
//    private func groupTransactionsByDate(transactions: [Transaction]) {
//        //var dict: [String: [Transaction]] = [:]
//        let trans = Dictionary(grouping: transactions) { (transaction) -> DateComponents in
//            let transDate = self.convertISO8601StringToDate(isoString: transaction.transactionDate) ?? Date.now
//            let date = Calendar.current.dateComponents([.day], from: (transDate))
//            return date
//        }
//
//        print("groupTransactionsByDate: ", trans)
//        print("groupTransactionsByDate Length: ", trans.count)
//    }
    

}
