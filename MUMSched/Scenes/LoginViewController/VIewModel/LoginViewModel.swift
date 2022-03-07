//
//  LoginViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

protocol LoginViewModelDelegate: BaseProtocolDelegate {
    
    func showEmailErrorMessage(_ message: String)
    func showPasswordErrorMessage(_ message: String)
}

final class LoginViewModel: LoginViewDelegate {
    
    weak var view: LoginViewModelDelegate?
    var email = ""
    var password = ""
    
    func isValid(showError: Bool) -> Bool {
        guard showError else {
            return email.isValidEmail() && password.isValidPassword()
        }
        guard !email.isEmpty else {
            view?.showEmailErrorMessage("Required")
            return false
        }
        guard email.isValidEmail() else {
            view?.showEmailErrorMessage("Invalid email")
            return false
        }
        guard !password.isEmpty else {
            view?.showPasswordErrorMessage("Required")
            return false
        }
        guard password.isValidPassword() else {
            view?.showPasswordErrorMessage("Weak password")
            return false
        }
        return true
    }
    
    func login() {
        guard isValid(showError: true) else { return }
        
        API<User>.login.request(params: ["email": email, "password": password], completion: { [weak self] result in
            switch result {
            case .success(let user):
                User.current = user
                self?.view?.dismiss()
            case .failure(let error):
                self?.view?.error?(message: error.localizedDescription)
            }
        })
    }
}
