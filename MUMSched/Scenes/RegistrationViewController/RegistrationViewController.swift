//
//  RegistrationViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol RegistrationViewDelegate: AnyObject {
    
    var view: RegistrationViewModelDelegate? { get set}
    func load()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func moveRow(from: IndexPath, to: IndexPath)
    func didSelect(section: Int)
    func saveRegistration()
}

final class RegistrationViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: RegistrationViewDelegate) {
        let view = RegistrationViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            nav.modalPresentationStyle = .fullScreen
            controller.present(nav, animated: true)
        }
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let viewModel: RegistrationViewDelegate
    
    private init(viewModel: RegistrationViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Registration"
        saveButton.setTitle("Save", for: .normal)
        setupTableView()
        viewModel.load()
    }
    
    private func setupTableView() {
        tableView.registerNib(for: RegistrationTableViewCell.self)
        tableView.dragInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 54, right: 0)
    }
    
    @IBAction private func saveTouched(_ sender: UIButton) {
        viewModel.saveRegistration()
    }
}

// MARK: - RegistrationViewModelDelegate
extension RegistrationViewController: RegistrationViewModelDelegate {
    
    func reload() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension RegistrationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellComp = viewModel.cellForRow(at: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellComp.reuseId, for: indexPath)
        (cell as? DynamicCellComponent)?.updateUI(with: cellComp.data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Block"
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIButton()
//        view.tag = section
//        view.addTarget(self, action: #selector(sectionTouched(_:)), for: .touchUpInside)
//        view.setTitle("Block", for: .normal)
//        view.setTitleColor(.black, for: .normal)
//        view.backgroundColor = .white
//        return view
//    }
    
    @objc private func sectionTouched(_ sender: UIButton) {
        viewModel.didSelect(section: sender.tag)
    }
}

// MARK: - UITableViewDelegate
extension RegistrationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveRow(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let sameSection = sourceIndexPath.section == proposedDestinationIndexPath.section
        return sameSection ? proposedDestinationIndexPath : sourceIndexPath
    }
}

// MARK: - UITableViewDragDelegate
extension RegistrationViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = viewModel.cellForRow(at: indexPath)
        return [dragItem]
    }
}
