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
    
    private var courses: [Course] = []
    
    func load() {
        view?.startLoading?(completion: {
            API<[Course]>.listCourses.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let courses):
                        self?.courses = courses
                        self?.view?.update?()
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
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
        AddCourseViewController.present(in: view.navigationController ?? view,
                                        viewModel: AddCourseViewModel(course: course, delegate: self))
    }
    
    func addNewCourse() {
        guard let view = view as? UIViewController else { return }
        AddCourseViewController.present(in: view.navigationController ?? view,
                                        viewModel: AddCourseViewModel(delegate: self))
    }
}

// MARK: - UpdateDelegate
extension CoursesViewModel: UpdateDelegate {
    
    func shouldUpdate() {
        API<[Course]>.listCourses.request(completion: { [weak self] result in
            switch result {
            case .success(let courses):
                self?.courses = courses
                self?.view?.update?()
            case .failure: break
            }
        })
    }
}
