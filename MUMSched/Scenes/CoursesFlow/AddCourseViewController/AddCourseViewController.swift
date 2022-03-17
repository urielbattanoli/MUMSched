//
//  AddCourseViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

protocol AddCourseViewDelegate: AnyObject {
    
    var view: AddCourseViewModelDelegate? { get set }
    var title: String { get }
    var sendButtonTitle: String { get }
    var code: String { get set }
    var name: String { get set }
    var description: String { get set }
    var showDelete: Bool { get }
    
    func isValid(showError: Bool) -> Bool
    func sendTouched()
    func deleteTouched()
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func addPrerequisiteTouched()
}

final class AddCourseViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: AddCourseViewDelegate) {
        let view = AddCourseViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var idInputView: InputView!
    @IBOutlet private weak var nameInputView: InputView!
    @IBOutlet private weak var descInputView: InputView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private let viewModel: AddCourseViewDelegate
    
    private init(viewModel: AddCourseViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        changeButtonState()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(for: RegistrationTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupView() {
        title = viewModel.title
        sendButton.setTitle(viewModel.sendButtonTitle, for: .normal)
        deleteButton.isHidden = !viewModel.showDelete
        
        idInputView.headerLabel.text = "Course ID"
        idInputView.textField.placeholder = "ID"
        idInputView.text = viewModel.code
        idInputView.textChanged = { [weak self] in self?.idTextChanged() }
        
        nameInputView.headerLabel.text = "Course Name"
        nameInputView.textField.placeholder = "Type the course name"
        nameInputView.text = viewModel.name
        nameInputView.textChanged = { [weak self] in self?.nameTextChanged() }
        
        descInputView.headerLabel.text = "Course Description"
        descInputView.textField.placeholder = "Type the course description"
        descInputView.text = viewModel.description
        descInputView.textChanged = { [weak self] in self?.descTextChanged() }
    }
    
    private func idTextChanged() {
        viewModel.code = idInputView.text ?? ""
        idInputView.hideErrorMessage()
        idInputView.textField.rightView = nil
        changeButtonState()
    }
    
    private func nameTextChanged() {
        viewModel.name = nameInputView.text ?? ""
        nameInputView.hideErrorMessage()
        nameInputView.textField.rightView = nil
        changeButtonState()
    }
    
    private func descTextChanged() {
        viewModel.description = descInputView.text ?? ""
        descInputView.hideErrorMessage()
        descInputView.textField.rightView = nil
        changeButtonState()
    }
    
    private func changeButtonState() {
        let isValid = viewModel.isValid(showError: false)
        sendButton.alpha = isValid ? 1 : 0.6
    }
    
    @IBAction private func sendTouched(_ sender: UIButton) {
        viewModel.sendTouched()
    }
    
    @IBAction private func deleteTouched(_ sender: UIButton) {
        viewModel.deleteTouched()
    }
    
    @IBAction private func addPrerequisiteTouched(_ sender: UIButton) {
        viewModel.addPrerequisiteTouched()
    }
}

// MARK: - AddCourseViewModelDelegate
extension AddCourseViewController: AddCourseViewModelDelegate {
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func showIdError() {
        idInputView.showErrorMessage("Required")
    }
    
    func showNameError() {
        nameInputView.showErrorMessage("Required")
    }
}

// MARK: - UITableViewDataSource
extension AddCourseViewController: UITableViewDataSource {
    
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
extension AddCourseViewController: UITableViewDelegate {
}
