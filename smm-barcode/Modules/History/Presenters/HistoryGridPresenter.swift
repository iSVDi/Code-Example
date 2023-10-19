//
//  HistoryGridPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 08.04.2023.
//

import Foundation
import UIKit

class HistoryGridPresenter: HistoryLayoutPresenterProtocol {

    weak var delegate: HistoryLayoutPresenterDelegate?
    private let collectionView = ViewsFactory.filesCollectionView()
    private lazy var adapter = {
        let adapter = CollectionViewAdapter(collectionView: collectionView)
        adapter.configureCollectionView(configurator: self, reusableCellClass: HistoryCollectionViewCell.self)
        return adapter
    }()

    var items: [ScanModel] = []
    var selectedItems: [ScanModel] = []
    var isEditing: Bool {
        get {
            return collectionView.allowsMultipleSelection
        } set {
            collectionView.allowsMultipleSelection = newValue
        }
    }

    init() {
        setupCollectionView()
    }

    func getView() -> UIView {
        return collectionView
    }

    func showItems(_ items: [ScanModel]) {
        self.items = items
        adapter.reloadData()
    }

    // MARK: - Helpers

    private func setupCollectionView() {
        collectionView.backgroundColor = .appLightGray3
    }

}

// MARK: - Collection View Adapter Configurator

extension HistoryGridPresenter: CollectionViewAdapterConfigurator {

    func didSelectItemAtIndexPath(_ path: IndexPath) {
        if collectionView.allowsMultipleSelection {
            (collectionView.cellForItem(at: path) as? HistoryCollectionViewCell)?.toggleSelection()
        }
        let model = items[path.row]
        delegate?.didSelectCell(with: model)
    }

    func didDeselectItemAtIndexPath(_ path: IndexPath) {
        if collectionView.allowsMultipleSelection {
            (collectionView.cellForItem(at: path) as? HistoryCollectionViewCell)?.toggleSelection()
        }
        let model = items[path.row]
        delegate?.didDeselectCell(with: model)
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return items.count
    }

    func configureCell(_ cell: UICollectionViewCell, atIndexPath path: IndexPath) -> UICollectionViewCell {
        (cell as? HistoryCollectionViewCell)?.update(
            item: items[path.item],
            selectionState: selectedItems.first(where: { $0.id == items[path.item].id }) != nil
        )
        return cell
    }

    func sizeForItemAtIndexPath(_ path: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: HistoryCellConstants.cellHeight)
    }

    func contextMenuConfigurator(contextMenuConfigurationForItemAt indexPath: IndexPath) -> UIContextMenuConfiguration? {
        let model = items[indexPath.row]
        return delegate?.contextMenuConfigurator(item: model)
    }
}
