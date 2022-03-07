//
//  CoursesViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

protocol CoursesViewDelegate: AnyObject {
    
    var view: CoursesViewModelDelegate? { get set}
    func load()
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func didSelectRowAt(at indexPath: IndexPath)
    func addNewCourse()
}

final class CoursesViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: CoursesViewDelegate) {
        let view = CoursesViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .crossDissolve //TODO: remove
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let viewModel: CoursesViewDelegate
    
    private init(viewModel: CoursesViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        viewModel.load()
    }
    
    private func setupView() {
        title = "Courses"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self,
                                  action: #selector(addTouched))
        add.tintColor = .black
        navigationItem.rightBarButtonItem = add
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(for: CourseTableViewCell.self)
    }
    
    @objc private func addTouched() {
        viewModel.addNewCourse()
    }
}

// MARK: - UITableViewDataSource
extension CoursesViewController: UITableViewDataSource {
    
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
extension CoursesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(at: indexPath)
    }
}

// MARK: - CoursesViewModelDelegate
extension CoursesViewController: CoursesViewModelDelegate {
    
    func update() {
        tableView.reloadData()
    }
}
