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
    
    private var blocks: [Block] = []
    
    func load() {
        view?.startLoading?(completion: {
            API<[Block]>.listBlocks.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let blocks):
                        self?.blocks = blocks
                        self?.view?.reload()
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
    }
    
    func titleForSection(_ section: Int) -> String {
        return "Block \(blocks[section].id)"
    }
    
    func numberOfSections() -> Int {
        return blocks.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
//        guard selected == section else { return 0 }
        return blocks[section].blockCourses?.count ?? 0
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        guard let data = blocks[indexPath.section].blockCourses?[indexPath.row] else { return nil }
        return CellComponent(reuseId: RegistrationTableViewCell.reuseId, data: data)
    }
    
    func moveRow(from: IndexPath, to: IndexPath) {
//        let mover = blocks[from.section].blockCourses?.remove(at: from.row)
//        blocks[to.section].blockCourses?.insert(mover, at: to.row)
    }
    
    func didSelect(section: Int) {
        selected = selected == section ? nil : section
        view?.reload()
    }
    
    func saveRegistration() {
        
    }
}
