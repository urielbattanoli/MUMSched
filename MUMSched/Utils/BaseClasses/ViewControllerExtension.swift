//
//  ViewControllerExtension.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

extension UIViewController {
    
    @objc func stopLoading(completion: (() -> Void)?) {
        guard var topController = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow})
                .first?
                .rootViewController else { return }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        guard let controller = topController as? UIAlertController else { return }
        controller.dismiss(animated: true, completion: completion)
    }
    
    @objc func startLoading(completion: (() -> Void)?) {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .large
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: completion)
    }
    
    @objc func showSimpleAlertController(_ title: String?, message: String?, actions: [UIAlertAction]?, cancel: Bool, style: UIAlertController.Style) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let actions: [UIAlertAction] = actions ?? []
        
        if actions.count == 0 {
            alertC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        } else {
            for action in actions {
                alertC.addAction(action)
            }
            
            if cancel {
                alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
        }
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    @objc func pushToVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    @objc func dismiss() {
        dismiss(animated: true)
    }
    
    @objc func popView() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func error(message: String?) {
        showSimpleAlertController("Ops",
                                  message: message ?? "Error",
                                  actions: nil,
                                  cancel: false,
                                  style: .alert)
    }
}
