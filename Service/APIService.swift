//
//  APIService.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 10/04/2022.
//

import RxSwift
import RxCocoa

protocol APIServiceProtocol {
    func login(username: String, password: String) -> Driver<AuthenticationResponse>
    func register(username: String, password: String) -> Driver<AuthenticationResponse>
    func getBalanceInfo() -> Driver<Balance>
    func getTransactionHistory() -> Driver<TransactionResponse>
}


final class APIService: APIServiceProtocol {
    private final let baseURL = "https://green-thumb-64168.uc.r.appspot.com/"

    private final let loginEndpoint = "login"
    private final let registerEndpoint = "register" //bonus
    private final let balanceEndpoint = "balance"
    private final let transactionsEndpoint = "transactions"
    private final let payeesEndpoint = "payees" //bonus
    private final let transferEndpoint = "transfer" //bonus
    
    func login(username: String, password: String) -> Driver<AuthenticationResponse> {
        guard let url = URL(string: baseURL + loginEndpoint) else { return Driver.empty() }
        let paramater = ["username" : username, "password" : password]
        let resource = Resource<AuthenticationResponse>(url: url, parameter: paramater)
        
        return URLRequest.postWithParamaters(resource: resource).asDriver(onErrorRecover: {error in
            let errorResponse = AuthenticationResponse(status: "failed", token: "", username: nil, accountNo: nil)
            return Driver.just(errorResponse)
        })
    }
    
    func register(username: String, password: String) -> Driver<AuthenticationResponse> {
        guard let url = URL(string: baseURL + registerEndpoint) else { return Driver.empty() }
        
        let paramater = ["username" : username, "password" : password]
        let resource = Resource<AuthenticationResponse>(url: url, parameter: paramater)
        
        return URLRequest.postWithParamaters(resource: resource).asDriver(onErrorRecover: {error in
            let errorResponse = AuthenticationResponse(status: "failed", token: "", username: nil, accountNo: nil)
            return Driver.just(errorResponse)
        })
    }
    
    func getBalanceInfo() -> Driver<Balance> {
        guard let url = URL(string: baseURL + balanceEndpoint) else { return Driver.empty() }
        let resource = Resource<Balance>(url: url, parameter: nil)
        return URLRequest.load(resource: resource).asDriver(onErrorRecover: {_ in
            return Driver.empty()
        })
    }
    
    func getTransactionHistory() -> Driver<TransactionResponse> {
        guard let url = URL(string: baseURL + transactionsEndpoint) else { return Driver.empty() }
        let resource = Resource<TransactionResponse>(url: url, parameter: nil)
        return URLRequest.load(resource: resource).asDriver(onErrorRecover: {_ in
            return Driver.empty()
        })
    }
    
}
