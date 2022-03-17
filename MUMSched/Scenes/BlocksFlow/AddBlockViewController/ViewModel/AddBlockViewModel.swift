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
    func reloadTableView()
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
    
    private var blockCourses: [AddBlockCourse] = []
    private var allFaculties: [Faculty] = []
    private var allCourses: [Course] = []
    
    init(block: Block? = nil, delegate: UpdateDelegate) {
        self.block = block
        self.updateDelegate = delegate
        self.name = block == nil ? "" : "Block \(block!.id)"
        self.startDate = block?.start
        self.blockCourses = block?.blockCourses?.map { AddBlockCourse(course: $0.course,
                                                                      faculty: $0.faculty,
                                                                      seats: $0.availableSeats) } ?? []
        load()
    }
    
    private func load() {
        API<[Faculty]>.listUsers.request(params: ["role": UserRole.FACULTY.rawValue], completion: { [weak self] result in
            guard case .success(let faculties) = result else { return }
            self?.allFaculties = faculties
        })
        
        API<[Course]>.listCourses.request(completion: { [weak self] result in
            guard case .success(let courses) = result else { return }
            self?.allCourses = courses
        })
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
    
    private func blockCoursesParams() -> [JSON] {
        return blockCourses.map { BlockCourseCreation(courseId: $0.course.id,
                                                      capacity: $0.seats,
                                                      facultyId: $0.faculty.id,
                                                      blockId: block?.id ?? 0).toDictionary() }
    }

    private func addBlock() {
        guard let start = Utils.formatDate(date: startDate) else { return }
        API<Block>.addBlock.request(params: ["startDate": start], completion: { [weak self] result in
            switch result {
            case .success(let block):
                self?.updateBlock(id: block.id, add: true)
            case .failure(let error):
                self?.view?.stopLoading?(completion: {
                    self?.view?.error?(message: error.localizedDescription)
                })
            }
        })
    }
    
    private func updateBlock(id: Int, add: Bool = false) {
        guard let start = Utils.formatDate(date: startDate) else { return }
        var params: JSON = ["startDate": start]
        if !blockCourses.isEmpty {
            params["blockCourses"] = blockCoursesParams()
        }
        API<Block>.updateBlock(id: id).request(params: params, completion: { [weak self] result in
            self?.view?.stopLoading?(completion: {
                switch result {
                case .success:
                    let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                        self?.updateDelegate.shouldUpdate()
                        if add {
                            self?.view?.dismiss()
                        }
                    }
                    self?.view?.showSimpleAlertController("Success",
                                                          message: add ? "Block created!" : "Block updated!",
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
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return blockCourses.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let course = blockCourses[indexPath.row]
        let data = BlockCourseCellVM(blockCourse: course,
                                     deleteAction: deleteTouched(index: indexPath.row))
        return CellComponent(reuseId: BlockCourseTableViewCell.reuseId, data: data)
    }
    
    private func deleteTouched(index: Int) -> () -> Void {
        return { [weak self] in
            self?.blockCourses.remove(at: index)
            self?.view?.reloadTableView()
        }
    }
    
    func addCourseTouched() {
        guard let view = view as? UIViewController else { return }
        let viewModel = AddBlockCourseViewModel(allCourses: allCourses,
                                                allFaculties: allFaculties,
                                                delegate: self)
        AddBlockCourseViewController.present(in: view.navigationController ?? view,
                                       viewModel: viewModel)
    }
}

// MARK: - AddBlockCourseDelegate
extension AddBlockViewModel: AddBlockCourseDelegate {
    
    func didAddBlockCourse(_ blockCourse: AddBlockCourse) {
        blockCourses.append(blockCourse)
        view?.reloadTableView()
    }
}
