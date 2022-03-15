//
//  RegistrationViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol RegistrationViewModelDelegate: AnyObject {
    func reload()
}

final class RegistrationViewModel: RegistrationViewDelegate {
    
    var view: RegistrationViewModelDelegate?
    
    var selected: Int?
    
    private var courses: [String] = ["SWE", "WAP", "FPP", "MPP", "SWA", "ALG"]
    
    func load() {
        
    }
    
    func numberOfSections() -> Int {
        return 4
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
//        guard selected == section else { return 0 }
        return courses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = courses[indexPath.row]
        return CellComponent(reuseId: RegistrationTableViewCell.reuseId, data: data)
    }
    
    func moveRow(from: IndexPath, to: IndexPath) {
        let mover = courses.remove(at: from.row)
        courses.insert(mover, at: to.row)
        print(courses)
    }
    
    func didSelect(section: Int) {
        selected = selected == section ? nil : section
        view?.reload()
    }
    
    func saveRegistration() {
        
    }
}
