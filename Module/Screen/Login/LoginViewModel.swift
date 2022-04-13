//
//  LoginViewModel.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 09/04/2022.
//

import Foundation
import RxCocoa
import RxSwift

protocol LoginProtocol {
    func routeToDasboardPage()
}

class LoginViewModel {
    weak var view: (UIViewController & LoginProtocol)? = nil
    let disposeBag = DisposeBag()
    
    var loginButtonTapped: Driver<Void> = .never()
    var registerButtonTapped: Driver<Void> = .never()
    
    var username = BehaviorRelay<String?>(value: "")
    var password = BehaviorRelay<String?>(value: "")
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    private let apiService: APIServiceProtocol
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func transform() {
        
        let callLoginAPI = loginButtonTapped.withLatestFrom(username.asDriver()).withLatestFrom(password.asDriver()) {($0, $1)}.flatMapLatest({ (username: String?, password: String?) -> Driver<AuthenticationResponse> in
            self.isLoading.accept(true)
            return self.apiService.login(username: username!, password: password!)
        })
        
        let loginSuccess = callLoginAPI.filter({$0.status == "success"}).do(onNext: { [weak self] loginResponse in
            guard let self = self else {return}
            print("Login Response: ", loginResponse)
            UserDefaults.standard.set(loginResponse.token, forKey: "appToken")
            UserDefaults.standard.set(loginResponse.accountNo, forKey: "accountNo")
            self.isLoading.accept(false)
            self.view?.routeToDasboardPage()
        })
        

        let loginFailed = callLoginAPI.filter({$0.status == "failed"}).do(onNext: { [weak self] loginResponse in
            guard let self = self else {return}
            self.isLoading.accept(false)
            print("Failed Response: ", loginResponse)
        })

        
        disposeBag.insert(
            loginSuccess.drive(),
            loginFailed.drive()
        )
    }
}
