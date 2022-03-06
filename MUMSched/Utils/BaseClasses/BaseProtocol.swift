//
//  BaseProtocol.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

@objc protocol BaseProtocolDelegate {
    @objc optional func update()
    @objc optional func error(message: String?)
    @objc optional func success(message: String?)
    @objc optional func stopLoading(completion: (() -> Void)?)
    @objc optional func startLoading(completion: (() -> Void)?)
    func pushToVC(_ vc: UIViewController)
    func presentVC(_ vc: UIViewController)
    func dismiss()
    func popView()
    
    func showSimpleAlertController(_ title: String?, message: String?, actions: [UIAlertAction]?, cancel: Bool, style: UIAlertController.Style)
}
