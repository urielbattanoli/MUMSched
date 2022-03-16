//
//  AddBlockViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

protocol AddBlockViewModelDelegate: BaseProtocolDelegate {
    
    func showStartDateError()
    func showNameError()
}

final class AddBlockViewModel: AddBlockViewDelegate {
    
    weak var view: AddBlockViewModelDelegate?
    
    private var updateDelegate: UpdateDelegate
    private var block: Block?
    private var isEdit: Bool { return block != nil }
    var title: String { isEdit ? "Edit Block" : "Add Block" }
    var sendButtonTitle: String { isEdit ? "Save Block" : "Add Block" }
    var name: String = ""
    var startDate: Date?
    
    var showDelete: Bool { return isEdit }
    
    init(block: Block? = nil, delegate: UpdateDelegate) {
        self.block = block
        self.updateDelegate = delegate
        self.name = block?.name ?? ""
        self.startDate = block?.start
    }
    
    func isValid(showError: Bool) -> Bool {
        guard !showError else {
            if name.isEmpty {
                view?.showNameError()
                return false
            }
            if startDate == nil {
                view?.showStartDateError()
                return false
            }
            return true
        }
        return startDate != nil && !name.isEmpty
    }
    
    private func addBlock() {
        guard let start = Utils.formatDate(date: startDate) else { return }
        API<Course>.addBlock.request(params: ["name": self.name, "startDate": start], completion: { [weak self] result in
            self?.view?.stopLoading?(completion: {
                switch result {
                case .success:
                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                        self?.updateDelegate.shouldUpdate()
                        self?.view?.dismiss()
                    }
                    self?.view?.showSimpleAlertController("Success",
                                                          message: "Block created!",
                                                          actions: [ok],
                                                          cancel: false,
                                                          style: .alert)
                case .failure(let error):
                    self?.view?.error?(message: error.localizedDescription)
                }
            })
        })
    }
    
    private func updateBlock(id: Int) {
        guard let start = Utils.formatDate(date: startDate) else { return }
        API<Course>.updateBlock(id: id).request(params: ["name": self.name, "startDate": start], completion: { [weak self] result in
            self?.view?.stopLoading?(completion: {
                switch result {
                case .success:
                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                        self?.updateDelegate.shouldUpdate()
                    }
                    self?.view?.showSimpleAlertController("Success",
                                                          message: "Block updated!",
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
            guard let id = self.block?.id else {
                self.addBlock()
                return
            }
            self.updateBlock(id: id)
        })
    }
    
    func deleteTouched() {
        guard let id = self.block?.id else { return }
        let ok = UIAlertAction(title: "Delete Now", style: .default) { _ in
            self.deleteBlock(id: id)
        }
        self.view?.showSimpleAlertController("Delete Block",
                                             message: "Are you sure you want to delete this block",
                                             actions: [ok],
                                             cancel: true,
                                             style: .alert)
    }
    
    private func deleteBlock(id: Int) {
        view?.startLoading?(completion: {
            API<EmptyResult>.deleteBlock(id: id).request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success:
                        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                            self?.updateDelegate.shouldUpdate()
                            self?.view?.dismiss()
                        }
                        self?.view?.showSimpleAlertController("Success",
                                                              message: "Block deleted!",
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

