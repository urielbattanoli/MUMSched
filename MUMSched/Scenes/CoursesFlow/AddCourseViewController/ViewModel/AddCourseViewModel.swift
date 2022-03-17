//
//  AddCourseViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation
import UIKit

protocol UpdateDelegate {
    func shouldUpdate()
}

protocol AddCourseViewModelDelegate: BaseProtocolDelegate {
    
    func showIdError()
    func showNameError()
    func reloadTableView()
}

final class AddCourseViewModel: AddCourseViewDelegate {
    
    weak var view: AddCourseViewModelDelegate?
    
    private var updateDelegate: UpdateDelegate
    private var course: Course?
    private var isEdit: Bool { return course != nil }
    private let allCourses: [Course]
    private var prerequisites: [Course]
    var title: String { isEdit ? "Edit Course" : "Add Course" }
    var sendButtonTitle: String { isEdit ? "Save Course" : "Add Course" }
    var code: String = ""
    var name: String = ""
    var description: String = ""
    
    var showDelete: Bool { return isEdit }
    
    init(allCourses: [Course], course: Course? = nil, delegate: UpdateDelegate) {
        self.allCourses = allCourses.filter { $0.id != course?.id }
        self.course = course
        self.updateDelegate = delegate
        self.code = course?.code ?? ""
        self.name = course?.name ?? ""
        self.description = course?.description ?? ""
        self.prerequisites = allCourses.filter { course?.preRequisites.contains($0.code) ?? false }
    }
    
    func isValid(showError: Bool) -> Bool {
        guard !showError else {
            if code.isEmpty {
                view?.showIdError()
                return false
            }
            if name.isEmpty {
                view?.showNameError()
                return false
            }
            return true
        }
        return !code.isEmpty && !name.isEmpty
    }
    
    private var params: JSON {
        let list = prerequisites.map { $0.code }
        return ["code": code, "description": description, "name": name, "preRequisites": list]
    }
    
    private func addCourse() {
        API<Course>.addCourse.request(params: params, completion: { [weak self] result in
            self?.view?.stopLoading?(completion: {
                switch result {
                case .success:
                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                        self?.updateDelegate.shouldUpdate()
                        self?.view?.dismiss()
                    }
                    self?.view?.showSimpleAlertController("Success",
                                                          message: "Course created!",
                                                          actions: [ok],
                                                          cancel: false,
                                                          style: .alert)
                case .failure(let error):
                    self?.view?.error?(message: error.localizedDescription)
                }
            })
        })
    }
    
    private func updateCourse(id: Int) {
        API<Course>.updateCourse(id: id).request(params: params, completion: { [weak self] result in
            self?.view?.stopLoading?(completion: {
                switch result {
                case .success:
                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                        self?.updateDelegate.shouldUpdate()
                    }
                    self?.view?.showSimpleAlertController("Success",
                                                          message: "Course updated!",
                                                          actions: [ok],
                                                          cancel: false,
                                                          style: .alert)
                case .failure(let error):
                    self?.view?.error?(message: error.localizedDescription)
                }
            })
        })
    }
    
    func sendTouched() {
        guard isValid(showError: true) else { return }
        
        view?.startLoading?(completion: {
            guard let id = self.course?.id else {
                self.addCourse()
                return
            }
            self.updateCourse(id: id)
        })
    }
    
    func deleteTouched() {
        guard let id = self.course?.id else { return }
        let ok = UIAlertAction(title: "Delete Now", style: .default) { _ in
            self.deleteCourse(id: id)
        }
        self.view?.showSimpleAlertController("Delete Course",
                                             message: "Are you sure you want to delete this course",
                                             actions: [ok],
                                             cancel: true,
                                             style: .alert)
    }
    
    private func deleteCourse(id: Int) {
        view?.startLoading?(completion: {
            API<EmptyResult>.deleteCourse(id: id).request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success:
                        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                            self?.updateDelegate.shouldUpdate()
                            self?.view?.dismiss()
                        }
                        self?.view?.showSimpleAlertController("Success",
                                                              message: "Course deleted!",
                                                              actions: [ok],
                                                              cancel: false,
                                                              style: .alert)
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return prerequisites.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let course = prerequisites[indexPath.row]
        let data = RegistrationCellVM(showIcon: false,
                                      course: course,
                                      deleteAction: deleteTouched(course: course))
        return CellComponent(reuseId: RegistrationTableViewCell.reuseId, data: data)
    }
    
    private func deleteTouched(course: Course) -> () -> Void {
        return { [weak self] in
            self?.prerequisites.removeAll(where: { $0.id == course.id })
            self?.view?.reloadTableView()
        }
    }
    
    func addPrerequisiteTouched() {
        guard let view = view as? UIViewController else { return }
        let courses = allCourses.filter { !prerequisites.contains($0) }
        let viewModel = SelectCourseViewModel(courses: courses,
                                              delegate: self)
        SelectCourseViewController.present(in: view.navigationController ?? view,
                                           viewModel: viewModel)
    }
}

// MARK: - SelectCourseViewDelegate
extension AddCourseViewModel: SelectCourseDelegate {
    
    func didSelectCourse(_ course: Course) {
        prerequisites.append(course)
        view?.reloadTableView()
    }
}
