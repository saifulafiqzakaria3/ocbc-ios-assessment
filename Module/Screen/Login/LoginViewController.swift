//
//  LoginViewController.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 09/04/2022.
//

import UIKit
import RxSwift
import RxBiBinding

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var viewModel: LoginViewModel!
    let disposeBag = DisposeBag()
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        viewModel.view = self
        transformInput()
        viewModel.transform()
    }
    
    func setupDisplay() {
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
    }
    
    func transformInput() {
        viewModel.loginButtonTapped = loginButton.rx.tap.asDriver()
        viewModel.registerButtonTapped = registerButton.rx.tap.asDriver()
        
        disposeBag.insert(
            usernameTextField.rx.text <-> viewModel.username,
            passwordTextField.rx.text <-> viewModel.password
        )
    }

}


extension LoginViewController: LoginProtocol {
    func routeToDasboardPage() {
        guard let transactionDashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "TransactionDashboardViewController") else { return }
        self.navigationController?.pushViewController(transactionDashboardVC, animated: true)
    }
}
