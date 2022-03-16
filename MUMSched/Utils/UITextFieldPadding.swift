//
//  UITextFieldPadding.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

final class UITextFieldPadding: UITextField {
    
    private enum TextFieldFormatting {
        case custom
        case noFormatting
    }
    
    private var formattingPattern: String = "" {
        didSet {
            self.maxLength = formattingPattern.count
        }
    }
    private let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    private var replacementChar: Character = "*"
    private var secureTextReplacementChar: Character = "\u{25cf}"
    private var maxLength = 0
    private var formatting : TextFieldFormatting = .noFormatting {
        didSet {
            switch formatting {
            default:
                self.maxLength = 0
            }
        }
    }
    private var _textWithoutSecureBullets = ""
    private var finalStringWithoutFormatting : String {
        return _textWithoutSecureBullets.keepOnlyDigits(isHexadecimal: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerForNotifications()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        registerForNotifications()
    }
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"),
                                               object: self)
    }
    
    public func setFormatting(_ formattingPattern: String, replacementChar: Character) {
        self.formattingPattern = formattingPattern
        self.replacementChar = replacementChar
        self.formatting = .custom
    }
    
    @objc public func textDidChange() {
        var superText: String { return super.text ?? "" }
        let currentTextForFormatting: String
        
        if superText.count > _textWithoutSecureBullets.count {
            currentTextForFormatting = _textWithoutSecureBullets + superText[superText.index(superText.startIndex, offsetBy: _textWithoutSecureBullets.count)...]
        } else if superText.count == 0 {
            _textWithoutSecureBullets = ""
            currentTextForFormatting = ""
        } else {
            currentTextForFormatting = String(_textWithoutSecureBullets[..<_textWithoutSecureBullets.index(_textWithoutSecureBullets.startIndex, offsetBy: superText.count)])
        }
        if formatting != .noFormatting && currentTextForFormatting.count > 0 && formattingPattern.count > 0 {
            let tempString = currentTextForFormatting.keepOnlyDigits(isHexadecimal: true)
            
            var finalText = ""
            var finalSecureText = ""
            
            var stop = false
            
            var formatterIndex = formattingPattern.startIndex
            var tempIndex = tempString.startIndex
            
            while !stop {
                let formattingPatternRange = formatterIndex ..< formattingPattern.index(formatterIndex, offsetBy: 1)
                if formattingPattern[formattingPatternRange] != String(replacementChar) {
                    
                    finalText = finalText + formattingPattern[formattingPatternRange]
                    finalSecureText = finalSecureText + formattingPattern[formattingPatternRange]
                    
                } else if tempString.count > 0 {
                    
                    let pureStringRange = tempIndex ..< tempString.index(tempIndex, offsetBy: 1)
                    
                    finalText = finalText + tempString[pureStringRange]
                    
                    // we want the last number to be visible
                    if tempString.index(tempIndex, offsetBy: 1) == tempString.endIndex {
                        finalSecureText = finalSecureText + tempString[pureStringRange]
                    } else {
                        finalSecureText = finalSecureText + String(secureTextReplacementChar)
                    }
                    
                    tempIndex = tempString.index(after: tempIndex)
                }
                
                formatterIndex = formattingPattern.index(after: formatterIndex)
                
                if formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }
            
            _textWithoutSecureBullets = finalText
            
            let newText = finalText
            if newText != superText {
                super.text = finalText
            }
        }
        
        // Let's check if we have additional max length restrictions
        if maxLength > 0 {
            if superText.count > maxLength {
                super.text = String(superText[..<superText.index(superText.startIndex, offsetBy: maxLength)])
                _textWithoutSecureBullets = String(_textWithoutSecureBullets[..<_textWithoutSecureBullets.index(_textWithoutSecureBullets.startIndex, offsetBy: maxLength)])
            }
        }
    }
}

private extension String {
    
    func keepOnlyDigits(isHexadecimal: Bool) -> String {
        let ucString = self.uppercased()
        let validCharacters = isHexadecimal ? "0123456789ABCDEFGHIJKLMNOPQRSTUVXYWZ" : "0123456789"
        let characterSet: CharacterSet = CharacterSet(charactersIn: validCharacters)
        let stringArray = ucString.components(separatedBy: characterSet.inverted)
        let allNumbers = stringArray.joined(separator: "")
        return allNumbers
    }
}

extension UITextField {
    
    func addDoneButtonOnKeyboard(selector: (Any?, Selector)? = nil, showCancel: Bool = false) {
        let frame = CGRect.init(x: 0,
                                y: 0,
                                width: UIScreen.main.bounds.width,
                                height: 50)
        let doneToolbar = UIToolbar(frame: frame)
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)

        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: selector?.0 ?? self,
                                   action: selector?.1 ?? #selector(self.doneButtonAction))
        done.tintColor = .black
        var items: [UIBarButtonItem] = []
        if showCancel {
            let cancel = UIBarButtonItem(title: "Cancel",
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.doneButtonAction))
            cancel.tintColor = .black
            items.append(cancel)
        }
        items += [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction() {
        self.resignFirstResponder()
    }
}
