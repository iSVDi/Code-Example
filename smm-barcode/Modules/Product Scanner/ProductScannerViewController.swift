//
//  ProductScannerViewController.swift
//  smm-barcode
//
//  Created by Daniil on 10.04.2023.
//

import TinyConstraints
import UIKit

class ProductScannerViewController: UIViewController {

    // MARK: - Properties

    let searchController = ViewsFactory.defaultSearchController()
    lazy var presenter = ProductScannerPresenter(controller: self)
    var scanProductHandler: (() -> Void)?

    // MARK: - Life Cycle

    required init(scanProductHandler: @escaping () -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.scanProductHandler = scanProductHandler
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        scanProductHandler = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }

    // MARK: - Helpers

    private func commonInit() {
        setViews()
        setDismissLeftBarButtonItem()
    }

    private func setViews() {
        title = ^String.Product.productScanner
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        view.backgroundColor = .appLightGray3

        let rightBarButton = UIBarButtonItem(image: .barcode)
        rightBarButton.addTarget(presenter, action: #selector(presenter.scanProductHandler))
        navigationItem.rightBarButtonItem = rightBarButton
    }

}

// MARK: - UISearchResultsUpdating

extension ProductScannerViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter.searchRequest(query: searchController.searchBar.text ?? "")
    }

}
