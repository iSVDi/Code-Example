//
//  CollectionViewAdapter.swift
//  smm-video-editor
//
//  Created by Timur Pervov on 27.01.2022.
//

import UIKit

protocol CollectionViewAdapterConfigurator: AnyObject {
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func configureCell(_ cell: UICollectionViewCell, atIndexPath path: IndexPath) -> UICollectionViewCell
    func didSelectItemAtIndexPath(_ path: IndexPath)
    func didDeselectItemAtIndexPath(_ path: IndexPath)
    func sizeForItemAtIndexPath(_ path: IndexPath) -> CGSize
    func contextMenuConfigurator(contextMenuConfigurationForItemAt indexPath: IndexPath) -> UIContextMenuConfiguration?
}

extension CollectionViewAdapterConfigurator {
    func numberOfSections() -> Int { return 1 }
}

class CollectionViewAdapter: NSObject {

    let collectionView: UICollectionView
    private weak var configurator: CollectionViewAdapterConfigurator!
    private var reuseIdentifier: String?
    private var headerIdentifier: String!

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView

        super.init()
    }

    func configureCollectionView(configurator: CollectionViewAdapterConfigurator, reusableCellClass: UICollectionViewCell.Type? = nil) {
        self.configurator = configurator
        if let cell = reusableCellClass {
            let identifier = String(describing: cell)
            collectionView.register(cell, forCellWithReuseIdentifier: identifier)
            reuseIdentifier = identifier
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func insertCellsAtIndexPaths(_ paths: [IndexPath]) {
        collectionView.insertItems(at: paths)
    }

    func reloadCellsAtIndexPaths(_ paths: [IndexPath]) {
        collectionView.reloadItems(at: paths)
    }

    func reloadData() {
        collectionView.reloadData()
    }

}

extension CollectionViewAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configurator.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configurator.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let identifier = reuseIdentifier {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            return configurator.configureCell(cell, atIndexPath: indexPath)
        } else {
            return configurator.configureCell(UICollectionViewCell(), atIndexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configurator.didSelectItemAtIndexPath(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configurator.didDeselectItemAtIndexPath(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return configurator.sizeForItemAtIndexPath(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return configurator.contextMenuConfigurator(contextMenuConfigurationForItemAt: indexPath)
    }

}
