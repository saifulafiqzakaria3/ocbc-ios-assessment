//
//  RegisterAccountViewModel.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 13/04/2022.
//

import Foundation
import RxCocoa
import RxSwift

protocol RegisterAccountProtocol {
    func routeToDasboardPage()
    func routeToLoginPage()
    func updatePasswordMatchingUI(isPasswordSame: Bool)
}

class RegisterAccountViewModel {
    weak var view: (UIViewController & RegisterAccountProtocol)? = nil
    let disposeBag = DisposeBag()
    
    var loginButtonTapped: Driver<Void> = .never()
    var registerButtonTapped: Driver<Void> = .never()
    
    var username = BehaviorRelay<String?>(value: "")
    var password = BehaviorRelay<String?>(value: "")
    var confirmPassword = BehaviorRelay<String?>(value: "")
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    private let apiService: APIServiceProtocol
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func transform() {
        
        let checkPasswordMatching = self.registerButtonTapped.withLatestFrom(confirmPassword.asDriver()).withLatestFrom(password.asDriver()){($0, $1)}.filter({$0 != nil && $1 != nil && !$0!.isEmpty && !$1!.isEmpty}).map({$0 == $1})

        let displayErrorNotMatch = checkPasswordMatching.do(onNext: { same in
            self.view?.updatePasswordMatchingUI(isPasswordSame: same)
        })
        
        let callRegisterAPI = checkPasswordMatching.filter({$0}).withLatestFrom(username.asDriver()).withLatestFrom(password.asDriver()) {($0, $1)}.flatMapLatest({(username: String?, password: String?) -> Driver<AuthenticationResponse> in
            self.isLoading.accept(true)
            return self.apiService.register(username: username!, password: password!)
        })
        
        let registerSuccess = callRegisterAPI.filter({$0.status == "success"}).do(onNext: { [weak self] registerResponse in
            guard let self = self else {return}
            UserDefaults.standard.set(registerResponse.token, forKey: "appToken")
            UserDefaults.standard.set(self.username.value, forKey: "username")
            self.isLoading.accept(false)
            self.view?.routeToDasboardPage()
        })
        
        let registerFailed = callRegisterAPI.filter({$0.status == "failed"}).do(onNext: { [weak self] registerResponse in
            guard let self = self else {return}
            self.isLoading.accept(false)
        })
        
        let popBackToLogin = self.loginButtonTapped.do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.view?.routeToLoginPage()
        })
        
        disposeBag.insert(
            displayErrorNotMatch.drive(),
            registerSuccess.drive(),
            registerFailed.drive(),
            popBackToLogin.drive()
        )
    }
}

