//
//  AddBlockCourseViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

struct AddBlockCourse {
    let course: Course
    let faculty: Faculty
    let seats: Int
}

protocol AddBlockCourseDelegate {
    
    func didAddBlockCourse(_ blockCourse: AddBlockCourse)
}

protocol AddBlockCourseViewModelDelegate: BaseProtocolDelegate {
    func update()
    func showSeatsError()
}

final class AddBlockCourseViewModel: AddBlockCourseViewDelegate {
    
    weak var view: AddBlockCourseViewModelDelegate?
    
    var title: String = "Add Block"
    var sendButtonTitle: String = "Add Block"
    var seats: Int = 0
    var courseName: String { return course?.name ?? "Select Course" }
    var facultyName: String { return faculty?.name ?? "Select Faculty" }
    
    private var course: Course?
    private var faculty: Faculty?
    private let allCourses: [Course]
    private let allFaculties: [Faculty]
    private let delegate: AddBlockCourseDelegate
    
    init(allCourses: [Course], allFaculties: [Faculty], delegate: AddBlockCourseDelegate) {
        self.allCourses = allCourses
        self.allFaculties = allFaculties
        self.delegate = delegate
    }
    
    func isValid(showError: Bool) -> Bool {
        guard !showError else {
            if seats == 0 {
                view?.showSeatsError()
                return false
            }
            return course != nil && faculty != nil
        }
        return seats != 0 && course != nil && faculty != nil
    }
    
    func sendTouched() {
        guard isValid(showError: true) else { return }
        let bc = AddBlockCourse(course: course!,
                                faculty: faculty!,
                                seats: seats)
        delegate.didAddBlockCourse(bc)
        view?.dismiss()
    }
    
    func courseTouched() {
        guard let view = view as? UIViewController else { return }
        let courses = allCourses.filter { $0 != course }
        let viewModel = SelectCourseViewModel(courses: courses,
                                              delegate: self)
        SelectCourseViewController.present(in: view.navigationController ?? view,
                                           viewModel: viewModel)
    }
    
    func facultyTouched() {
        guard let view = view as? UIViewController else { return }
        let faculties = allFaculties.filter { $0 != faculty }
        let viewModel = SelectFacultyViewModel(faculties: faculties,
                                               delegate: self)
        SelectCourseViewController.present(in: view.navigationController ?? view,
                                           viewModel: viewModel)
    }
}

// MARK: - SelectCourseViewDelegate
extension AddBlockCourseViewModel: SelectCourseDelegate {
    
    func didSelectCourse(_ course: Course) {
        self.course = course
        view?.update()
    }
}

// MARK: - SelectFacultyDelegate
extension AddBlockCourseViewModel: SelectFacultyDelegate {
    func didSelectFaculty(_ faculty: Faculty) {
        self.faculty = faculty
        view?.update()
    }
}
