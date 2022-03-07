//
//  InputView.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

let availableChars = CharacterSet(arrayLiteral: "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","_", ".")

protocol InputViewDelegate: AnyObject {
    func textFieldShouldReturn(_ textField: UITextField)
}

enum InputType {
    case email, password, name, nickname, address, phone, money, none, number, cpf
}

final class InputView: NibDesignable {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var textField: UITextFieldPadding! {
        didSet { setState(isEditable: true) }
    }
    @IBOutlet weak var accessoryButton: UIButton!

    weak var delegate: InputViewDelegate?
    private var nicknameRules = false
    var textChanged: (() -> Void)?
    var shouldBeginEditing: Bool = true
    var actionBeforeEditing: (() -> Void)?
    var accessoryAction: (() -> Void)?

    private var textFieldColor: UIColor {
        return errorMessageLabel.isHidden ? (textIsEmpty ? .placeholderText : .darkText) : .red
    }
    
    private var textIsEmpty: Bool {
        return (text ?? "").isEmpty
    }
    
    private var inputLimit: Int {
        switch inputType {
        case .cpf: return 14
        case .phone: return 15
        default: return Int.max
        }
    }
    
    var accessoryTitle: String? {
        set {
            accessoryButton.isHidden = false
            accessoryButton.setTitle(newValue, for: .normal)
        }
        get {
            return accessoryButton.title(for: .normal)
        }
    }
    
    var text: String? {
        set {
            textField.text = newValue
            textField.textColor = textFieldColor
        }
        get {
            return textField.text
        }
    }
    
    var inputType: InputType = .none {
        didSet {
            switch inputType {
            case .email:
                textField.keyboardType = .emailAddress
                textField.textContentType = .emailAddress
            case .password:
                textField.isSecureTextEntry = true
            case .name:
                textField.textContentType = .name
                textField.autocapitalizationType = .words
            case .nickname:
                nicknameRules = true
            case .address:
                textField.textContentType = .fullStreetAddress
                textField.autocapitalizationType = .words
            case .phone:
                textField.textContentType = .telephoneNumber
                textField.keyboardType = .phonePad
            case .money:
                textField.keyboardType = .numberPad
            case .number:
                textField.keyboardType = .decimalPad
            case .cpf:
                textField.keyboardType = .numberPad
            case .none:
                textField.autocapitalizationType = .sentences
            }
        }
    }
    
    func setState(isEditable: Bool) {
        textField.isUserInteractionEnabled = isEditable
        textField.layer.borderWidth = isEditable ? 2 : 0
        textField.delegate = self
    }
    
    func showErrorMessage(_ message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
        textField.layer.borderColor = UIColor.red.cgColor
        textField.textColor = .red
    }
    
    func hideErrorMessage() {
        errorMessageLabel.isHidden = true
        textField.layer.borderColor = UIColor.darkText.cgColor
        textField.textColor = textFieldColor
    }
    
    override func setTheme() {
        super.setTheme()
        
        headerLabel.textColor = .darkText
        errorMessageLabel.textColor = .red
        textField.setCorner(6)
        textField.textColor = textFieldColor
        textField.layer.borderColor = errorMessageLabel.isHidden ? UIColor.darkText.cgColor : UIColor.red.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "",
                                                             attributes: [.foregroundColor : UIColor.placeholderText])
        accessoryButton.setTitleColor(.darkText, for: .normal)
    }
    
    var maximum: Decimal = 999_999_999.99
    
    private var lastText = ""
    @IBAction private func textChanged(_ sender: UITextField) {
        textChanged?()
        
        switch inputType {
        case .phone:
            let text = textField?.text ?? ""
            let result = text.removeSpecialCharacters()
            guard !(text.count <= lastText.count && (lastText.last == "-" || lastText.last == " " || lastText.last == ")")) else {
                lastText = text
                return
            }
            lastText = text
            textField.text = result.applyPhoneMask()
        case .money:
            let result = textField?.text?.removeMoneySpecialCharacters() ?? ""
            guard result.count > lastText.count else {
                lastText = result
                return
            }
            lastText = result
            textField.text = result.currencyInputFormatting()
        case .cpf:
            let result = textField?.text?.removeSpecialCharacters() ?? ""
            guard result.count > lastText.count else {
                lastText = result
                return
            }
            lastText = result
            textField.text = result.applyCPFMask()
        default:
            break
        }
    }
    
    @IBAction private func accessoryButtonClicked(_ sender: UIButton) {
        accessoryAction?()
    }
}

extension InputView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        actionBeforeEditing?()
        return shouldBeginEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isAvailable = string.rangeOfCharacter(from: availableChars) != nil
        guard string.isEmpty || !nicknameRules || isAvailable else {
            shake()
            return false
        }
        
        let oldText = textField.text!
        let newString = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: string)
        return newString.count <= inputLimit
    }
    
    private func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
    }
}
