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
}

final class AddCourseViewModel: AddCourseViewDelegate {
    
    weak var view: AddCourseViewModelDelegate?
    
    private var updateDelegate: UpdateDelegate
    private var course: Course?
    private var isEdit: Bool { return course != nil }
    var title: String { isEdit ? "Edit Course" : "Add Course" }
    var sendButtonTitle: String { isEdit ? "Save Course" : "Add Course" }
    var code: String = ""
    var name: String = ""
    
    init(course: Course? = nil, delegate: UpdateDelegate) {
        self.course = course
        self.updateDelegate = delegate
        self.code = course?.code ?? ""
        self.name = course?.name ?? ""
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
    
    func sendTouched() {
        guard isValid(showError: true) else { return }
        
        view?.startLoading?(completion: {
            guard let id = self.course?.id else {
                API<Course>.addCourse.request(params: ["code": self.code, "name": self.name], completion: { [weak self] result in
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
                return
            }
            API<Course>.updateCourse(id: id).request(params: ["code": self.code, "name": self.name], completion: { [weak self] result in
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
        })
    }
}
