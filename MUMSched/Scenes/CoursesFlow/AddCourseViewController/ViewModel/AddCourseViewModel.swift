//
//  AddCourseViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

protocol AddCourseViewModelDelegate: BaseProtocolDelegate {
    
    func showIdError()
    func showNameError()
}

final class AddCourseViewModel: AddCourseViewDelegate {
    
    weak var view: AddCourseViewModelDelegate?
    
    private var course: String?
    var title: String { course == nil ? "Add Course" : "Edit Course" }
    var sendButtonTitle: String { course == nil ? "Add Course" : "Save Course" }
    var id: String = ""
    var name: String = ""
    
    init(course: String? = nil) {
        self.course = course
        self.name = course ?? ""
    }
    
    func isValid(showError: Bool) -> Bool {
        guard !showError else {
            if id.isEmpty {
                view?.showIdError()
                return false
            }
            if name.isEmpty {
                view?.showNameError()
                return false
            }
            return true
        }
        return !id.isEmpty && !name.isEmpty
    }
    
    func sendTouched() {
        guard isValid(showError: true) else { return }
        //TODO: Request
    }
}
