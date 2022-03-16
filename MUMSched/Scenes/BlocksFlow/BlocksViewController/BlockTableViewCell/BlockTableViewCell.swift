//
//  BlockTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

final class BlockTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
}

// MARK: - DynamicCellComponent
extension BlockTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? Block else { return }
        let start = Utils.formatDate(date: data.start) ?? ""
        titleLabel.text = data.name + " - " + "Starts on \(start)"
    }
}
