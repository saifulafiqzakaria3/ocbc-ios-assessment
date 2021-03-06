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
    let loginSpinner: UIActivityIndicatorView = { () -> UIActivityIndicatorView in
        let loginSpinner = UIActivityIndicatorView(style: .medium)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        return loginSpinner
    }()
    
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
        passwordTextField.isSecureTextEntry = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        usernameErrorLabel.text = "Username is required"
        passwordErrorLabel.text = "Password is required"
        
        loginButton.addSubview(loginSpinner)
        loginSpinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        loginSpinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func transformInput() {
        viewModel.loginButtonTapped = loginButton.rx.tap.asDriver()
        viewModel.registerButtonTapped = registerButton.rx.tap.asDriver()

        let usernameValidate = usernameTextField.rx.text.map({$0?.isEmpty})
        let passwordValidate = passwordTextField.rx.text.map({$0?.isEmpty})
        let enableLoginButton = Observable.combineLatest(usernameValidate, passwordValidate, viewModel.isLoading).map({ (nameIsEmpty, passwordIsEmpty, isLoading) in
            return !(nameIsEmpty ?? true) && !(passwordIsEmpty ?? true) && !isLoading
        })
        
        disposeBag.insert(
            usernameTextField.rx.text <-> viewModel.username,
            passwordTextField.rx.text <-> viewModel.password,
            enableLoginButton.bind(to: loginButton.rx.isEnabled),
            viewModel.isLoading.bind(to: loginSpinner.rx.isAnimating)
        )
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.count < 1 {
            if textField === usernameTextField {
                usernameErrorLabel.isHidden = false
            } else {
                passwordErrorLabel.isHidden = false
            }
        } else {
            if textField === usernameTextField {
                usernameErrorLabel.isHidden = true
            } else {
                passwordErrorLabel.isHidden = true
            }
        }
    }
}


extension LoginViewController: LoginProtocol {
    func routeToDasboardPage(apiService: APIServiceProtocol) {
        guard let dashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDashboardViewController") as? AccountDashboardViewController else { return }
        dashboardVC.viewModel = AccountDashboardViewModel(apiService: apiService)
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    func routeToRegisterPage(apiService: APIServiceProtocol) {
        guard let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterAccountViewController") as? RegisterAccountViewController else { return }
        registerVC.viewModel = RegisterAccountViewModel(apiService: apiService)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
}
