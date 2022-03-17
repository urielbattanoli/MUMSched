//
//  BlockCourseTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/17/22.
//

import UIKit

struct BlockCourseCellVM {
    
    let blockCourse: AddBlockCourse
    let deleteAction: (() -> Void)?
}

final class BlockCourseTableViewCell: NibRegistrableTableViewCell {
    
    @IBOutlet private weak var courseCodeLabel: UILabel!
    @IBOutlet private weak var courseNameLabel: UILabel!
    @IBOutlet private weak var facultyNameLabel: UILabel!
    @IBOutlet private weak var seatsLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var deleteAction: (() -> Void)?
    
    @IBAction private func deleteTouched(_ sender: UIButton) {
        deleteAction?()
    }
}

// MARK: - DynamicCellComponent
extension BlockCourseTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? BlockCourseCellVM else { return }
        self.deleteAction = data.deleteAction
        courseCodeLabel.text = data.blockCourse.course.code
        courseNameLabel.text = data.blockCourse.course.name
        facultyNameLabel.text = data.blockCourse.faculty.name
        seatsLabel.text = "\(data.blockCourse.seats) Available Seats"
    }
}
