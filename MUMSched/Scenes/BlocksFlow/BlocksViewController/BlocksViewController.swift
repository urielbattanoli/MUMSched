//
//  BlocksViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

protocol BlocksViewDelegate: AnyObject {
    
    var view: BlocksViewModelDelegate? { get set }
    func load()
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func didSelectRow(at indexPath: IndexPath)
    func addNewBlock()
}

final class BlocksViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: BlocksViewDelegate) {
        let view = BlocksViewController(viewModel: viewModel)
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
    
    private let viewModel: BlocksViewDelegate
    
    private init(viewModel: BlocksViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.load()
        setupView()
    }
    
    private func setupView() {
        title = "Blocks"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self,
                                  action: #selector(addTouched))
        add.tintColor = .black
        navigationItem.rightBarButtonItem = add
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(for: BlockTableViewCell.self)
        tableView.dragInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func addTouched() {
        viewModel.addNewBlock()
    }
}

// MARK: - BlocksViewModelDelegate
extension BlocksViewController: BlocksViewModelDelegate {
    
    func update() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension BlocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellComp = viewModel.cellForRow(at: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellComp.reuseId, for: indexPath)
        (cell as? DynamicCellComponent)?.updateUI(with: cellComp.data)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension BlocksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
    }
}
