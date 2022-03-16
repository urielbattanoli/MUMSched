//
//  SelectCourseViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol SelectCourseViewDelegate: AnyObject {
    
    var view: SelectCourseViewModelDelegate? { get set}
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func didSelectRow(at indexPath: IndexPath)
}

final class SelectCourseViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: SelectCourseViewDelegate) {
        let view = SelectCourseViewController(viewModel: viewModel)
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
    
    private let viewModel: SelectCourseViewDelegate
    
    private init(viewModel: SelectCourseViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Course"
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(for: RegistrationTableViewCell.self)
        tableView.dragInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - FacultyCoursesViewModelDelegate
extension SelectCourseViewController: SelectCourseViewModelDelegate {
    
}

// MARK: - UITableViewDataSource
extension SelectCourseViewController: UITableViewDataSource {
    
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
extension SelectCourseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
    }
}
