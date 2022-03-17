//
//  BlocksViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

protocol BlocksViewModelDelegate: BaseProtocolDelegate {
    
    func update()
}

final class BlocksViewModel: BlocksViewDelegate {
    
    weak var view: BlocksViewModelDelegate?
    
    private var blocks: [Block] = []
    
    func load() {
        view?.startLoading?(completion: {
            API<[Block]>.listBlocks.request(completion: { [weak self] result in
                self?.view?.stopLoading?(completion: {
                    switch result {
                    case .success(let blocks):
                        self?.blocks = blocks
                        self?.view?.update()
                    case .failure(let error):
                        self?.view?.error?(message: error.localizedDescription)
                    }
                })
            })
        })
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return blocks.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> CellComponent? {
        let data = blocks[indexPath.row]
        return CellComponent(reuseId: BlockTableViewCell.reuseId, data: data)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let view = view as? UIViewController else { return }
        let block = blocks[indexPath.row]
        let viewModel = AddBlockViewModel(block: block, delegate: self)
        AddBlockViewController.present(in: view.navigationController ?? view,
                                       viewModel: viewModel)
    }
    
    func addNewBlock() {
        guard let view = view as? UIViewController else { return }
        let viewModel = AddBlockViewModel(delegate: self)
        AddBlockViewController.present(in: view.navigationController ?? view,
                                       viewModel: viewModel)
    }
}

// MARK: - UpdateDelegate
extension BlocksViewModel: UpdateDelegate {
    
    func shouldUpdate() {
        API<[Block]>.listBlocks.request(completion: { [weak self] result in
            switch result {
            case .success(let blocks):
                self?.blocks = blocks
                self?.view?.update()
            case .failure: break
            }
        })
    }
}
