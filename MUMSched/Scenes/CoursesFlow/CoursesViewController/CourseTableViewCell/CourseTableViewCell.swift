//
//  CourseTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

final class CourseTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
}

// MARK: - DynamicCellComponent
extension CourseTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? Course else { return }
        codeLabel.text = data.code
        titleLabel.text = data.name
        let pre = "Prerequisites: " + data.preRequisites.joined(separator: ", ")
        let text = data.preRequisites.isEmpty ? "No Prerequisites" : pre
        descriptionLabel.text = data.description + " - \(text)"
    }
}
