//
//  CoursesViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

protocol CoursesViewModelDelegate: AnyObject {
    
    func updateView()
}

final class CoursesViewModel: CoursesViewDelegate {
    
    weak var view: CoursesViewModelDelegate?
    
    private var courses: [String] = ["Machine Learning", "Software Engineering", "Enterprise Architecture", "Web Programming", "Advanced Software Development"]
    
    func load() {
        view?.updateView()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return courses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = courses[indexPath.row]
        return CellComponent(reuseId: CourseTableViewCell.reuseId, data: data)
    }
    
    func didSelectRowAt(at indexPath: IndexPath) {
        
    }
    
    func addNewCourse() {
        
    }
}
