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
        API<[Course]>.listCourses.request(completion: { [weak self] result in
            guard case .success(let courses) = result else { return }
            self?.allCourses = courses
        })
        view?.startLoading?(completion: {
            API<FacultyCourses>.facultyCourses.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let course):
                        self?.selectedCourses = course.preferredCourses
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
        let data = SelectCourseCellVM(course: course,
                                      deleteAction: deleteTouched(course: course))
        return CellComponent(reuseId: SelectCourseTableViewCell.reuseId, data: data)
    }
    
    private func deleteTouched(course: Course) -> () -> Void {
        return { [weak self] in
            self?.selectedCourses.removeAll(where: { $0.id == course.id })
            self?.view?.update()
        }
    }
    
    func saveCourses() {
        guard let id = User.current?.id else { return }
        let params: JSON = ["facultyId": id, "preferredCoursesIds": selectedCourses.map { $0.id }]
        view?.startLoading?(completion: {
            API<EmptyResult>.saveFacultyCourses.request(params: params, completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success:
                        self?.view?.showSimpleAlertController("Success",
                                                              message: "Courses saved!",
                                                              actions: nil,
                                                              cancel: false,
                                                              style: .alert)
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
    }
    
    func addNewCourse() {
        guard let view = view as? UIViewController else { return }
        let courses = allCourses.filter { !selectedCourses.contains($0) }
        let viewModel = SelectCourseViewModel(courses: courses,
                                              delegate: self)
        SelectCourseViewController.present(in: view.navigationController ?? view,
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
