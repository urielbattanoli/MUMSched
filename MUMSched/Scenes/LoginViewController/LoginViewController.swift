//
//  LoginViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

protocol LoginViewDelegate: AnyObject {
    
    var view: LoginViewModelDelegate? { get set }
    var email: String { get set }
    var password: String { get set }
    
    func isValid(showError: Bool) -> Bool
    func login()
}

final class LoginViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: LoginViewDelegate) {
        let view = LoginViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .crossDissolve
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var emailInputView: InputView!
    @IBOutlet private weak var passwordInputView: InputView!
    @IBOutlet private weak var loginButton: UIButton!
    
    private let viewModel: LoginViewDelegate
    
    private init(viewModel: LoginViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        changeButtonState()
    }
    
    private func setupView() {
        title = "Login"
        emailInputView.textChanged = { [weak self] in self?.emailTextChanged() }
        emailInputView.headerLabel.text = "Email"
        emailInputView.textField.placeholder = "Type your email"
        emailInputView.inputType = .email
        emailInputView.delegate = self
        passwordInputView.textChanged = { [weak self] in self?.passwordTextChanged() }
        passwordInputView.inputType = .password
        passwordInputView.headerLabel.text = "Password"
        passwordInputView.textField.placeholder = "Type your password"
        passwordInputView.textField.returnKeyType = .go
        passwordInputView.delegate = self
        loginButton.setTitle("Login", for: .normal)
        loginButton.setCorner(6)
    }
    
    private func changeButtonState() {
        let isValid = viewModel.isValid(showError: false)
        loginButton.alpha = isValid ? 1 : 0.6
    }
    
    private func emailTextChanged() {
        emailInputView.hideErrorMessage()
        viewModel.email = emailInputView.text ?? ""
        changeButtonState()
    }
    
    private func passwordTextChanged() {
        passwordInputView.hideErrorMessage()
        viewModel.password = passwordInputView.text ?? ""
        changeButtonState()
    }
    
    @IBAction private func loginTouched(_ sender: UIButton) {
        viewModel.login()
    }
}

// MARK: - InputViewDelegate
extension LoginViewController: InputViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) {
        switch textField {
        case emailInputView.textField:
            passwordInputView.textField.becomeFirstResponder()
        case passwordInputView.textField:
            viewModel.login()
        default: break
        }
    }
}

// MARK: - LoginViewModelDelegate
extension LoginViewController: LoginViewModelDelegate {
    
    func showEmailErrorMessage(_ message: String) {
        emailInputView.showErrorMessage(message)
    }
    
    func showPasswordErrorMessage(_ message: String) {
        passwordInputView.showErrorMessage(message)
    }
}
