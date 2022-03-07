//
//  CoursesViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation
import UIKit

protocol CoursesViewModelDelegate: BaseProtocolDelegate {
    
}

final class CoursesViewModel: CoursesViewDelegate {
    
    weak var view: CoursesViewModelDelegate?
    
    private var courses: [String] = ["Machine Learning", "Software Engineering", "Enterprise Architecture", "Web Programming", "Advanced Software Development"]
    
    func load() {
        view?.update?()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return courses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = courses[indexPath.row]
        return CellComponent(reuseId: CourseTableViewCell.reuseId, data: data)
    }
    
    func didSelectRowAt(at indexPath: IndexPath) {
        guard let view = view as? UIViewController else { return }
        let course = courses[indexPath.row]
        AddCourseViewController.present(in: view, viewModel: AddCourseViewModel(course: course))
    }
    
    func addNewCourse() {
        guard let view = view as? UIViewController else { return }
        AddCourseViewController.present(in: view, viewModel: AddCourseViewModel())
    }
}
