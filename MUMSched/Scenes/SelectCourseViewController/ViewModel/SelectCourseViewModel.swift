//
//  SelectCourseViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import Foundation

protocol SelectCourseDelegate {
    func didSelectCourse(_ course: Course)
}

protocol SelectCourseViewModelDelegate: BaseProtocolDelegate {
    
}

final class SelectCourseViewModel: SelectCourseViewDelegate {
    
    weak var view: SelectCourseViewModelDelegate?
    var title: String { return "Select Course" }
    
    private var delegate: SelectCourseDelegate?
    private let courses: [Course]
    
    init(courses: [Course], delegate: SelectCourseDelegate) {
        self.courses = courses
        self.delegate = delegate
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return courses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = SelectCourseCellVM(course: courses[indexPath.row])
        return CellComponent(reuseId: SelectCourseTableViewCell.reuseId, data: data)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        delegate?.didSelectCourse(courses[indexPath.row])
        view?.dismiss()
    }
}
