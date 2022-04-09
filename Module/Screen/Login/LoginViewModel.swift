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
    
    var username = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    
//    private let movieService: MovieAPIServiceProtocol
//    init(movieService: MovieAPIServiceProtocol = MovieAPIService()) {
//        self.movieService = movieService
//    }
    
    func transform() {
        disposeBag.insert(
        )
    }
}
