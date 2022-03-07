//
//  StringExtension.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

typealias Mask = [Int: Character]

extension String {
    var localized: String {
        return NSLocalizedString(self, comment:"")
    }
    
    var localizedError: String {
        return localizedStringKey(tableName: "LocalizableError")
    }
    
    func localizedStringKey(bundle _: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: self, comment: "")
    }

    var initials: String {
        let characters = self.split(separator: " ").compactMap({ $0.first }).map({ String($0) })
        return [characters.first, characters.last].compactMap({ $0 }).joined().uppercased()
    }
    
    var numbers: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    var tabbedByNewLine: String {
        return "\t\(self.split(separator: "\n").joined(separator: "\n\t"))"
    }
    
    func removeSpecialCharacters() -> String {
        return self.filter("0123456789".contains)
    }
    
    func removeMoneySpecialCharacters() -> String {
        let string = self.replacingOccurrences(of: ",", with: ".")
        return string.filter("0123456789.,".contains)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidCPF() -> Bool {
        return self.removeSpecialCharacters().count == 11
    }
    
    func isValidPhone() -> Bool {
        let size = self.removeSpecialCharacters().count
        return size == 10 || size == 11
    }
    
    func isValidName() -> Bool {
        return self.count > 2
    }
    
    func isValidPassword() -> Bool {
        return self.count > 4
    }
    
    func isValidUsername() -> Bool {
        return self.count > 2
    }
    
    func asMask(joker: Character = "#") -> Mask {
        var mask: Mask = [:]
        for (i, char) in self.enumerated() {
            if char == joker { continue }
            mask[i] = char
        }
        return mask
    }
    func count(occurrencesOf char: Character = "#") -> Int {
        return self.filter({ $0 == char }).count
    }
    
    func applyPhoneMask() -> String {
        guard self.count > 0 else { return self }
        var formattedText = self.removeSpecialCharacters()
        let masks = (REGULARPHONE: "(##) ####-####".asMask(),
                     PHONE: "(##) #####-####".asMask())
        let mask = formattedText.count <= 10 ? masks.REGULARPHONE : masks.PHONE
        for i in mask.keys.sorted() {
            if i > formattedText.count { break }
            formattedText.insert(mask[i]!, at: formattedText.index(formattedText.startIndex, offsetBy: i))
        }
        return formattedText
    }
    
    func applyCPFMask() -> String {
        guard self.count > 0 else { return self }
        var formattedText = self.removeSpecialCharacters()
        let mask = "###.###.###-##".asMask()
        for i in mask.keys.sorted() {
            if i > formattedText.count { break }
            formattedText.insert(mask[i]!, at: formattedText.index(formattedText.startIndex, offsetBy: i))
        }
        return formattedText
    }
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = Locale.current.currencySymbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
    }
}

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}
