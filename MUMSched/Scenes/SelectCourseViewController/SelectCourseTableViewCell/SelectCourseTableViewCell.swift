//
//  SelectCourseTableViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/17/22.
//

import UIKit

struct SelectCourseCellVM {
    
    let course: Course
    let deleteAction: (() -> Void)?
    
    init(course: Course, deleteAction: (() -> Void)? = nil) {
        self.course = course
        self.deleteAction = deleteAction
    }
}

struct SelectFacultyCellVM {
    
    let faculty: Faculty
    let deleteAction: (() -> Void)?
    
    init(faculty: Faculty, deleteAction: (() -> Void)? = nil) {
        self.faculty = faculty
        self.deleteAction = deleteAction
    }
}

final class SelectCourseTableViewCell: NibRegistrableTableViewCell {
    
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
extension SelectCourseTableViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        if let data = data as? SelectCourseCellVM {
            codeLabel.text = data.course.code
            titleLabel.text = data.course.name
            deleteButton.isHidden = data.deleteAction == nil
            deleteAction = data.deleteAction
            addImageView.isHidden = data.deleteAction != nil
        }
        if let data = data as? SelectFacultyCellVM {
            codeLabel.isHidden = true
            titleLabel.text = data.faculty.name
            deleteButton.isHidden = data.deleteAction == nil
            deleteAction = data.deleteAction
            addImageView.isHidden = data.deleteAction != nil
        }
    }
}
