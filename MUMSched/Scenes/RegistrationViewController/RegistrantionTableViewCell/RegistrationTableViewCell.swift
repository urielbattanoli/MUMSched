//
//  RegistrationTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

final class RegistrationTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
}

// MARK: - DynamicCellComponent
extension RegistrationTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? Course else { return }
        codeLabel.text = data.code
        titleLabel.text = data.name
    }
}
