//
//  ViewExtension.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

extension UIView {
    
    func setCorner(_ value: CGFloat) {
        layer.cornerRadius = value
        clipsToBounds = true
    }
    
    func setAsCircle() {
        setCorner(frame.width / 2)
    }
}
