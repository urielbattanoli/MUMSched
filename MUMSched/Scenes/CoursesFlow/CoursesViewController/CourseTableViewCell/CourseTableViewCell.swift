//
//  CourseTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

final class CourseTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
}

// MARK: - DynamicCellComponent
extension CourseTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? String else { return }
        titleLabel.text = data
    }
}
