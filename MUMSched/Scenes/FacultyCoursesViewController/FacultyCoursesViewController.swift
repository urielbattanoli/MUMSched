//
//  FacultyCourseViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/15/22.
//

import UIKit

protocol FacultyCoursesViewDelegate: AnyObject {
    
    var view: FacultyCoursesViewModelDelegate? { get set}
    func load()
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func saveCourses()
    func addNewCourse()
}

final class FacultyCoursesViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: FacultyCoursesViewDelegate) {
        let view = FacultyCoursesViewController(viewModel: viewModel)
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
    @IBOutlet private weak var saveBackgroundView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    
    private let viewModel: FacultyCoursesViewDelegate
    
    private init(viewModel: FacultyCoursesViewDelegate) {
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
        title = "Courses"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self,
                                  action: #selector(addTouched))
        add.tintColor = .black
        navigationItem.rightBarButtonItem = add
        
        saveButton.setTitle("Save", for: .normal)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(for: SelectCourseTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction private func saveTouched(_ sender: UIButton) {
        viewModel.saveCourses()
    }
    
    @objc private func addTouched() {
        viewModel.addNewCourse()
    }
}

// MARK: - FacultyCoursesViewModelDelegate
extension FacultyCoursesViewController: FacultyCoursesViewModelDelegate {
    
    func update() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension FacultyCoursesViewController: UITableViewDataSource {
    
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
extension FacultyCoursesViewController: UITableViewDelegate {
}
