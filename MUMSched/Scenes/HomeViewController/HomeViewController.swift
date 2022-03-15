//
//  HomeViewController.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/14/22.
//

import UIKit

protocol HomeViewDelegate: AnyObject {
    
    var view: HomeViewModelDelegate? { get set }
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellForItem(at indexPath: IndexPath) -> CellComponent?
    func didSelectItem(at indexPath: IndexPath)
}

final class HomeViewController: UIViewController {
    
    static func present(in controller: UIViewController, viewModel: HomeViewDelegate) {
        let view = HomeViewController(viewModel: viewModel)
        viewModel.view = view
        if let nav = controller.navigationController {
            nav.pushViewController(view, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: view)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .crossDissolve //TODO: remove
            controller.present(nav, animated: true)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let viewModel: HomeViewDelegate
    
    private init(viewModel: HomeViewDelegate) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(for: HomeCollectionViewCell.self)
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellComp = viewModel.cellForItem(at: indexPath) else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellComp.reuseId, for: indexPath)
        (cell as? DynamicCellComponent)?.updateUI(with: cellComp.data)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let windowWidth = UIScreen.main.bounds.width - 10
        let width = windowWidth / 2
        return CGSize(width: width, height: width)
    }
}
