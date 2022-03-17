//
//  AddBlockViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

protocol AddBlockViewDelegate: AnyObject {
    
    var view: AddBlockViewModelDelegate? { get set }
    var title: String { get }
    var sendButtonTitle: String { get }
    var name: String { get set }
    var startDate: Date? { get set }
    var showDelete: Bool { get }
    
    func isValid(showError: Bool) -> Bool
    func sendTouched()
    func deleteTouched()
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRow(at indexPath: IndexPath) -> CellComponent?
    func addCourseTouched()
}

final class AddBlockViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: AddBlockViewDelegate) {
        let view = AddBlockViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var nameInputView: InputView!
    @IBOutlet private weak var startDateInputView: InputView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private let viewModel: AddBlockViewDelegate
    private lazy var startDatePickerView = UIDatePicker()
    private lazy var endDatePickerView = UIDatePicker()
    
    private init(viewModel: AddBlockViewDelegate) {
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
        tableView.registerNib(for: BlockCourseTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupView() {
        title = viewModel.title
        sendButton.setTitle(viewModel.sendButtonTitle, for: .normal)
        deleteButton.isHidden = !viewModel.showDelete
        
        nameInputView.headerLabel.text = "Block Name"
        nameInputView.textField.placeholder = "ex: Block 1"
        nameInputView.text = viewModel.name
        nameInputView.textChanged = { [weak self] in self?.nameTextChanged() }
        
        startDateInputView.headerLabel.text = "Block Start"
        startDateInputView.textField.placeholder = "Select the start date"
        startDateInputView.textField.addDoneButtonOnKeyboard()
        startDateInputView.text = Utils.formatDate(date: viewModel.startDate)
        addStartDatePicker()
    }
    
    private func nameTextChanged() {
        viewModel.name = nameInputView.text ?? ""
        nameInputView.hideErrorMessage()
        nameInputView.textField.rightView = nil
        changeButtonState()
    }
    
    private func addStartDatePicker() {
        startDatePickerView.datePickerMode = .date
        if let date = viewModel.startDate {
            startDatePickerView.date = date
        }
        startDatePickerView.preferredDatePickerStyle = .wheels
        startDateInputView.textField.inputView = startDatePickerView
        startDatePickerView.addTarget(self,
                                      action: #selector(datePickerStartValueChanged),
                                      for: .valueChanged)
    }
    
    @objc private func datePickerStartValueChanged(sender: UIDatePicker) {
        let date = sender.date
        viewModel.startDate = date
        startDateInputView.text = Utils.formatDate(date: date)
        startDateInputView.hideErrorMessage()
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
    
    @IBAction private func addCourseTouched(_ sender: UIButton) {
        viewModel.addCourseTouched()
    }
}

// MARK: - AddBlockViewModelDelegate
extension AddBlockViewController: AddBlockViewModelDelegate {
    
    func showStartDateError() {
        startDateInputView.showErrorMessage("Required")
    }
    
    func showNameError() {
        nameInputView.showErrorMessage("Required")
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension AddBlockViewController: UITableViewDataSource {
    
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
extension AddBlockViewController: UITableViewDelegate {
}
