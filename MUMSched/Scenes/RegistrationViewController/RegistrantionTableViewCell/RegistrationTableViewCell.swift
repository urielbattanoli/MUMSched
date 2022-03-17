//
//  RegistrationTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

final class RegistrationTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var facultyLabel: UILabel!
    @IBOutlet private weak var seatsLabel: UILabel!
}

// MARK: - DynamicCellComponent
extension RegistrationTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? BlockCourse else { return }
        
        codeLabel.text = data.course.code
        titleLabel.text = data.course.name
        facultyLabel.text = data.faculty.name
        seatsLabel.text = "\(data.availableSeats) Available Seats"
    }
}
