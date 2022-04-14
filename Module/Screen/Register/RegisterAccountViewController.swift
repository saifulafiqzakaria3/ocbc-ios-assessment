//
//  RegisterAccountViewController.swift
//  ocbc-ios-assessment
//
//  Created by Saiful.Afiq on 13/04/2022.
//

import UIKit
import RxSwift
import RxBiBinding

class RegisterAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    let registerSpinner: UIActivityIndicatorView = { () -> UIActivityIndicatorView in
        let regSpinner = UIActivityIndicatorView(style: .medium)
        regSpinner.translatesAutoresizingMaskIntoConstraints = false
        regSpinner.hidesWhenStopped = true
        return regSpinner
    }()
    
    var viewModel: RegisterAccountViewModel!
    let disposeBag = DisposeBag()
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setupDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        transformInput()
        viewModel.transform()
    }
    
    func setupDisplay() {
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        usernameErrorLabel.text = "Username is required"
        passwordErrorLabel.text = "Password is required"
        confirmPasswordErrorLabel.text = "Confirm password is required"
        
        registerButton.addSubview(registerSpinner)
        registerSpinner.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor).isActive = true
        registerSpinner.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor).isActive = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    func transformInput() {
        viewModel.loginButtonTapped = loginButton.rx.tap.asDriver()
        viewModel.registerButtonTapped = registerButton.rx.tap.asDriver()

        let usernameValidate = usernameTextField.rx.text.map({$0?.isEmpty})
        let passwordValidate = passwordTextField.rx.text.map({$0?.isEmpty})
        let confirmPasswordValidate = confirmPasswordTextField.rx.text.map({$0?.isEmpty})
        let enableLoginButton = Observable.combineLatest(usernameValidate, passwordValidate, confirmPasswordValidate, viewModel.isLoading).map({ (nameIsEmpty, passwordIsEmpty, confirmPasswordIsEmpty, isLoading) in
            return !(nameIsEmpty ?? true) && !(passwordIsEmpty ?? true) && !(confirmPasswordIsEmpty ?? true) && !isLoading
        })
                
        disposeBag.insert(
            usernameTextField.rx.text <-> viewModel.username,
            passwordTextField.rx.text <-> viewModel.password,
            confirmPasswordTextField.rx.text <-> viewModel.confirmPassword,
            enableLoginButton.bind(to: registerButton.rx.isEnabled),
            viewModel.isLoading.bind(to: registerSpinner.rx.isAnimating)
        )
    }
    
}

extension RegisterAccountViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.count < 1 {
            if textField === usernameTextField {
                usernameErrorLabel.isHidden = false
            } else if textField === passwordTextField {
                passwordErrorLabel.isHidden = false
            } else {
                confirmPasswordErrorLabel.isHidden = false
                confirmPasswordErrorLabel.text = "Confirm password is required"
            }
        } else {
            if textField === usernameTextField {
                usernameErrorLabel.isHidden = true
            } else if textField === passwordTextField {
                passwordErrorLabel.isHidden = true
            } else {
                confirmPasswordErrorLabel.isHidden = true
            }
        }
    }
}


extension RegisterAccountViewController: RegisterAccountProtocol {
    func routeToDasboardPage(apiService: APIServiceProtocol) {
        guard let dashboardVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountDashboardViewController") as? AccountDashboardViewController else { return }
        dashboardVC.viewModel = AccountDashboardViewModel(apiService: apiService)
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    
    func routeToLoginPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updatePasswordMatchingUI(isPasswordSame: Bool) {
        if isPasswordSame {
            confirmPasswordErrorLabel.isHidden = true
        } else {
            confirmPasswordErrorLabel.isHidden = false
            confirmPasswordErrorLabel.text = "Password not match"
        }
    }
}
