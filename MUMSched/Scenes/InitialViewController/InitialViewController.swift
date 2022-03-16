//
//  InitialViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

final class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if User.current == nil {
//            LoginViewController.present(in: self, viewModel: LoginViewModel())
//        } else {
            HomeViewController.present(in: self, viewModel: HomeViewModel())
//        }
    }
}
