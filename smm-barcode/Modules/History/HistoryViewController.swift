//
//  HistoryViewController.swift
//  smm-barcode
//
//  Created by Timur Pervov on 27.01.2022.
//

import AVKit
import PDFKit
import TinyConstraints
import Toast_Swift
import UIKit
import Vision

class HistoryViewController: UIViewController {

    enum PresentationMode: Int {
        case list = 0
        case grid
    }

    let searchController = ViewsFactory.defaultSearchController()
    private var presentationMode: PresentationMode = .list {
        didSet {
            presenter.handleLayoutChange(to: presentationMode)
            setupButtonsMenu()
        }
    }

    private lazy var presenter = HistoryPresenter(controller: self, layout: presentationMode)
    private let filePickerPresenter = IcloudCodeRecognizer()
    private lazy var galleryPresenter = GalleryScannerPresenter(controller: self)
    let filterButton = ViewsFactory.defaultButton(color: .appClear)
    private let moreOptionsButton = ViewsFactory.defaultButton(color: .appClear)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appLightGray3
        setupNavigationBar()
        setupButtonsMenu()
        // initial setup
        presenter.handleLayoutChange(to: presentationMode)
    }

    // MARK: - Helpers

    private func setupNavigationBar() {
        title = ^String.Root.historyTitle
        setDismissLeftBarButtonItem()

        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        filterButton.setImage(AppImage.filterImage.uiImageWith(tint: .appOrange), for: .normal)
        moreOptionsButton.setImage(AppImage.moreOptionsImage.uiImageWith(tint: .appOrange), for: .normal)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: moreOptionsButton), UIBarButtonItem(customView: filterButton)]
    }

    private func setupButtonsMenu() {
        if #available(iOS 14.0, *) {
            filterButton.menu = scansTypesFilterMenu()
            filterButton.showsMenuAsPrimaryAction = true

            moreOptionsButton.menu = moreOptionsMenu()
            moreOptionsButton.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
            filterButton.addTarget(self, action: #selector(filterButtonHandler), for: .touchDown)
            moreOptionsButton.addTarget(self, action: #selector(moreOptionsHandler), for: .touchDown)
        }
    }

    private func scansTypesFilterMenu() -> UIMenu {
        let titles = [
            ^String.ButtonTitles.allScans,
            ^String.ButtonTitles.barcodesOnly,
            ^String.ButtonTitles.qrCodesOnly,
            ^String.ButtonTitles.documentsOnly
        ]
        let filters: [ScanModel.ScanType?] = [nil, .barcode, .qr, .pdf]
        let zipParams = zip(titles, filters)

        let menuItems = zipParams.map { title, filter in
            let titleWithPrefix = presenter.itemsFilter == filter ? "    " + title : title
            return UIAction(title: titleWithPrefix, handler: { [weak self] _ in
                self?.presenter.handleFilter(by: filter)
                self?.setupButtonsMenu()
            })
        }
        let menu = UIMenu(title: "", image: nil, identifier: nil, children: menuItems)
        return menu
    }

    private func moreOptionsMenu() -> UIMenu {
        let iconsTitlePrefix = presentationMode == .grid ? "    " : ""
        let listTitlePrefix = presentationMode == .list ? "    " : ""
        var menuItems: [UIMenuElement] = [
            UIAction(title: iconsTitlePrefix + ^String.ButtonTitles.icons, handler: { [weak self] _ in
                self?.presentationMode = .grid
            }),
            UIAction(title: listTitlePrefix + ^String.ButtonTitles.list, handler: { [weak self] _ in
                self?.presentationMode = .list
            })
        ]
        let subMenuItems = [
            UIAction(title: ^String.ScannerMode.importFromCloud, handler: { [weak self] _ in
                self?.filePickerPresenter.present(in: self)

            }),
            UIAction(title: ^String.ScannerMode.importFromGallery, handler: { [weak self] _ in
                self?.galleryPresenter.start()
            }),
            UIAction(title: ^String.ButtonTitles.edit, handler: { [weak self] _ in
                guard let welf = self else {
                    return
                }
                welf.presenter.setupEditMode(!welf.presenter.layoutPresenter.isEditing)
            })
        ]

        let subMenu = UIMenu(title: "", options: .displayInline, children: subMenuItems)
        menuItems.append(subMenu)
        let menu = UIMenu(title: "", children: menuItems)
        return menu
    }

    // MARK: Handlers

    @objc private func filterButtonHandler() {
        let titles = [
            ^String.ButtonTitles.allScans,
            ^String.ButtonTitles.barcodesOnly,
            ^String.ButtonTitles.qrCodesOnly,
            ^String.ButtonTitles.documentsOnly
        ]
        let filters: [ScanModel.ScanType?] = [nil, .barcode, .qr, .pdf]
        let zipParams = zip(titles, filters)

        var actions = zipParams.map { title, filter in
            return UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.presenter.handleFilter(by: filter)
                self?.setupButtonsMenu()
            }
        }
        actions.append(.cancelAction)
        showSheetAlertController(actions: actions)
    }

    @objc private func moreOptionsHandler() {
        var actions: [UIAlertAction] = [
            UIAlertAction(title: ^String.ButtonTitles.icons, style: .default, handler: { [weak self] _ in
                self?.presentationMode = .grid
            }),
            UIAlertAction(title: ^String.ButtonTitles.list, style: .default, handler: { [weak self] _ in
                self?.presentationMode = .list
            }),
            UIAlertAction(title: ^String.ScannerMode.importFromCloud, style: .default, handler: { [weak self] _ in
                self?.filePickerPresenter.present(in: self)

            }),
            UIAlertAction(title: ^String.ScannerMode.importFromGallery, style: .default, handler: { [weak self] _ in
                self?.galleryPresenter.start()
            }),
            UIAlertAction(title: ^String.ButtonTitles.edit, style: .default, handler: { [weak self] _ in
                guard let welf = self else {
                    return
                }
                welf.presenter.setupEditMode(!welf.presenter.layoutPresenter.isEditing)
            })
        ]
        actions.append(.cancelAction)
        showSheetAlertController(actions: actions)
    }

}

// MARK: - UISearchResultsUpdating

extension HistoryViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter.handleSearch(query: searchController.searchBar.text?.lowercased() ?? "")
    }

}
