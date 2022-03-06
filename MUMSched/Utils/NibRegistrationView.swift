//
//  NibRegistrationView.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import UIKit

protocol NibRegistrableView: AnyObject {
    static var nibName: String { get }
    static var reuseId: String { get }
}

extension NibRegistrableView {
    static var nibName: String { return Utils.className(for: self) }
    static var reuseId: String { return Utils.className(for: self) }
    static var nib: UINib { return UINib(nibName: nibName, bundle: Bundle(for: self)) }
    static func instantiateFromNib() -> Any? { return self.nib.instantiate(withOwner: nil, options: nil).first }
}

typealias NibRegistrableTableViewCell = NibRegistrableView & UITableViewCell
typealias NibRegistrableTableHeaderFooterView = NibRegistrableView & UITableViewHeaderFooterView
typealias NibRegistrableCollectionViewCell = NibRegistrableView & UICollectionViewCell

extension UITableView {
    func registerNib(for cellClass: NibRegistrableTableViewCell.Type) {
        register(cellClass.nib, forCellReuseIdentifier: cellClass.reuseId)
    }
    
    func registerNib(for headerFooterView: NibRegistrableTableHeaderFooterView.Type) {
        register(headerFooterView.nib, forHeaderFooterViewReuseIdentifier: headerFooterView.reuseId)
    }
    
    func dequeueReusableCell<T: NibRegistrableTableViewCell>() -> T? {
        return dequeueReusableCell(withIdentifier: T.reuseId) as? T
    }
}

extension UICollectionView {
    func registerNib(for cellClass: NibRegistrableCollectionViewCell.Type) {
        register(cellClass.nib, forCellWithReuseIdentifier: cellClass.reuseId)
    }
    
    func dequeueReusableCell<T: NibRegistrableCollectionViewCell>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: T.reuseId, for: indexPath) as? T
    }
}
