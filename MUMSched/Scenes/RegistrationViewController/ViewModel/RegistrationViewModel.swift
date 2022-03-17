//
//  RegistrationViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol RegistrationViewModelDelegate: BaseProtocolDelegate {
    func reload()
}

final class RegistrationViewModel: RegistrationViewDelegate {
    
    weak var view: RegistrationViewModelDelegate?
    
    var selected: Int?
    
    private var registration: Registration?
    
    func load() {
        view?.startLoading?(completion: {
            API<Registration>.getRegistration.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let registration):
                        self?.registration = registration
                        self?.view?.reload()
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
    }
    
    func titleForSection(_ section: Int) -> String {
        return "Block \(registration?.blocks[section].blockId ?? 0)"
    }
    
    func numberOfSections() -> Int {
        return registration?.blocks.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
//        guard selected == section else { return 0 }
        return registration?.blocks[section].coursePriorities.count ?? 0
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        guard let data = registration?.blocks[indexPath.section].coursePriorities[indexPath.row] else { return nil }
        return CellComponent(reuseId: RegistrationTableViewCell.reuseId, data: data.blockCourse)
    }
    
    func moveRow(from: IndexPath, to: IndexPath) {
        guard let mover = registration?.blocks[from.section].coursePriorities.remove(at: from.row) else { return }
        registration?.blocks[to.section].coursePriorities.insert(mover, at: to.row)
        updatePriority(section: from.section)
    }
    
    private func updatePriority(section: Int) {
        for i in 1..<(registration?.blocks[section].coursePriorities.count ?? 0) + 1 {
            registration?.blocks[section].coursePriorities[i-1].priority = i
        }
    }
    
    func didSelect(section: Int) {
        selected = selected == section ? nil : section
        view?.reload()
    }
    
    private func params() -> JSON? {
        guard let blocks = registration?.blocks else { return nil }
        return ["blocks": blocks.map { ["blockId": $0.blockId,
                                        "coursePriorities": $0.coursePriorities.map { c in ["priority": c.priority,
                                                                                            "blockCourseId": c.blockCourse.id] }]}]
    }
    
    func saveRegistration() {
        guard let params = params() else { return }
        view?.startLoading?(completion: {
            API<EmptyResult>.saveRegistration.request(params: params, completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success:
                        self?.view?.showSimpleAlertController("Success",
                                                              message: "Registration saved!",
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
}
