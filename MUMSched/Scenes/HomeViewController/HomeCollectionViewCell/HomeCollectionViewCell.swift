//
//  HomeCollectionViewCell.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/14/22.
//

import UIKit

struct HomeCellData {
    let title: String
    let icon: UIImage
}

final class HomeCollectionViewCell: NibRegistrableCollectionViewCell {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titlelabel: UILabel!
}

// MARK: - DynamicCellComponent
extension HomeCollectionViewCell: DynamicCellComponent {
    
    func updateUI(with data: Any?) {
        guard let data = data as? HomeCellData else { return }
        
        iconImageView.image = data.icon
        titlelabel.text = data.title
    }
}
