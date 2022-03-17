//
//  SelectFacultyViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/17/22.
//

import Foundation

protocol SelectFacultyDelegate {
    func didSelectFaculty(_ faculty: Faculty)
}

final class SelectFacultyViewModel: SelectCourseViewDelegate {
    
    weak var view: SelectCourseViewModelDelegate?
    var title: String { return "Select Faculty" }
    
    private var delegate: SelectFacultyDelegate?
    private let faculties: [Faculty]
    
    init(faculties: [Faculty], delegate: SelectFacultyDelegate) {
        self.faculties = faculties
        self.delegate = delegate
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return faculties.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = SelectFacultyCellVM(faculty: faculties[indexPath.row])
        return CellComponent(reuseId: SelectCourseTableViewCell.reuseId, data: data)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        delegate?.didSelectFaculty(faculties[indexPath.row])
        view?.dismiss()
    }
}
