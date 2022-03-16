//
//  RegistrationTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

struct RegistrationCellVM {
    
    let showIcon: Bool
    let course: Course
    let deleteAction: (() -> Void)?
    
    init(showIcon: Bool, course: Course, deleteAction: (() -> Void)? = nil) {
        self.showIcon = showIcon
        self.course = course
        self.deleteAction = deleteAction
    }
}

final class RegistrationTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addImageView: UIImageView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var deleteAction: (() -> Void)?
    
    @IBAction private func deleteTouched(_ sender: UIButton) {
        deleteAction?()
    }
}

// MARK: - DynamicCellComponent
extension RegistrationTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? RegistrationCellVM else { return }
        iconImageView.isHidden = !data.showIcon
        codeLabel.text = data.course.code
        titleLabel.text = data.course.name
        deleteButton.isHidden = data.deleteAction == nil
        deleteAction = data.deleteAction
        addImageView.isHidden = data.showIcon || data.deleteAction != nil
    }
}
