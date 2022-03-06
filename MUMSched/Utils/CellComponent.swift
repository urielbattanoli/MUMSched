//
//  CellComponent.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/6/22.
//

import Foundation

struct SectionComponent {
    var cells: [CellComponent]
    
    init(cells: [CellComponent]) {
        self.cells = cells
    }
}

class CellComponent {
    let reuseId: String
    var data: Any?
    
    init(reuseId: String, data: Any? = nil) {
        self.reuseId = reuseId
        self.data = data
    }
}

protocol DynamicCellComponent: NibRegistrableView {
    func updateUI(with data: Any?)
}
