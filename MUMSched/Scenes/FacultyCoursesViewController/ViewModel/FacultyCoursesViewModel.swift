//
//  FacultyCourseViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol FacultyCoursesViewModelDelegate: BaseProtocolDelegate {
    
    func update()
}

final class FacultyCoursesViewModel: FacultyCoursesViewDelegate {
    
    weak var view: FacultyCoursesViewModelDelegate?
    
    private var selectedCourses: [Course] = []
    private var allCourses: [Course] = []
    
    func load() {
        view?.startLoading?(completion: {
            API<[Course]>.listCourses.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let courses):
                        self?.allCourses = courses
                        self?.selectedCourses = courses
                        self?.view?.update()
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
        view?.update()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return selectedCourses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let course = selectedCourses[indexPath.row]
        let data = RegistrationCellVM(showIcon: false,
                                      course: course,
                                      deleteAction: deleteTouched(course: course))
        return CellComponent(reuseId: RegistrationTableViewCell.reuseId, data: data)
    }
    
    private func deleteTouched(course: Course) -> () -> Void {
        return { [weak self] in
            self?.selectedCourses.removeAll(where: { $0.id == course.id })
            self?.view?.update()
        }
    }
    
    func saveCourses() {
        
    }
    
    func addNewCourse() {
        guard let view = view as? UIViewController else { return }
        let courses = allCourses.filter { !selectedCourses.contains($0) }
        let viewModel = SelectCourseViewModel(courses: courses,
                                              delegate: self)
        SelectCourseViewController.present(in: view,
                                           viewModel: viewModel)
    }
}

// MARK: - SelectCourseViewDelegate
extension FacultyCoursesViewModel: SelectCourseDelegate {
    
    func didSelectCourse(_ course: Course) {
        selectedCourses.append(course)
        view?.update()
    }
}
