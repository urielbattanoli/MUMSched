//
//  AddBlockCourseViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/16/22.
//

import UIKit

protocol AddBlockCourseViewDelegate: AnyObject {
    
    var view: AddBlockCourseViewModelDelegate? { get set }
    var title: String { get }
    var sendButtonTitle: String { get }
    var seats: Int { get set }
    var courseName: String { get }
    var facultyName: String { get }
    
    func isValid(showError: Bool) -> Bool
    func sendTouched()
    func courseTouched()
    func facultyTouched()
}

final class AddBlockCourseViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: AddBlockCourseViewDelegate) {
        let view = AddBlockCourseViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var courseControl: UIControl!
    @IBOutlet private weak var courseTitle: UILabel!
    @IBOutlet private weak var facultyControl: UIControl!
    @IBOutlet private weak var facultyTitle: UILabel!
    @IBOutlet private weak var seatsInputView: InputView!
    @IBOutlet private weak var sendButton: UIButton!
    
    private let viewModel: AddBlockCourseViewDelegate
    
    private init(viewModel: AddBlockCourseViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        title = "Add Block Course"
        courseControl.layer.cornerRadius = 6
        courseControl.layer.borderColor = UIColor.black.cgColor
        courseControl.layer.borderWidth = 2
        facultyControl.layer.cornerRadius = 6
        facultyControl.layer.borderColor = UIColor.black.cgColor
        facultyControl.layer.borderWidth = 2
        seatsInputView.headerLabel.text = "AvailableSeats"
        seatsInputView.textField.placeholder = "Seats"
        seatsInputView.text = viewModel.seats == 0 ? "" : "\(viewModel.seats)"
        seatsInputView.inputType = .number
        seatsInputView.textChanged = { [weak self] in self?.seatsTextChanged() }
    }
    
    private func seatsTextChanged() {
        viewModel.seats = Int(seatsInputView.text ?? "") ?? 0
        seatsInputView.hideErrorMessage()
        seatsInputView.textField.rightView = nil
        changeButtonState()
    }
    
    private func changeButtonState() {
        let isValid = viewModel.isValid(showError: false)
        sendButton.alpha = isValid ? 1 : 0.6
    }
    
    @IBAction private func courseTouched(_ sender: UIControl) {
        viewModel.courseTouched()
    }
    
    @IBAction private func facultyTouched(_ sender: UIControl) {
        viewModel.facultyTouched()
    }
    
    @IBAction private func sendTouched(_ sender: UIButton) {
        viewModel.sendTouched()
    }
}

// MARK: - AddBlockCourseViewModelDelegate
extension AddBlockCourseViewController: AddBlockCourseViewModelDelegate {
    
    func update() {
        courseTitle.text = viewModel.courseName
        facultyTitle.text = viewModel.facultyName
    }
    
    func showSeatsError() {
        seatsInputView.showErrorMessage("Required")
    }
}
