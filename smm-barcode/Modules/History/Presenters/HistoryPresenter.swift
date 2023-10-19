//
//  HistoryPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 08.04.2023.
//

import PDFKit
import TinyConstraints
import UIKit

protocol HistoryLayoutPresenterProtocol {
    var delegate: HistoryLayoutPresenterDelegate? { get set }
    func getView() -> UIView
    func showItems(_ items: [ScanModel])
    var isEditing: Bool { get set }
}

enum ScanContextMenuAction: String {
    case share
    case shareAsImage
    case shareAsText
    case delete
    case copy
}

protocol HistoryLayoutPresenterDelegate: AnyObject {
    func didSelectCell(with item: ScanModel)
    func didDeselectCell(with item: ScanModel)
    func removeItem(_ item: ScanModel)
    func handleContextAction(_ action: ScanContextMenuAction, item: ScanModel)
}

extension HistoryLayoutPresenterDelegate {

    func contextMenuConfigurator(item: ScanModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            var children: [UIMenuElement] = [
                UIAction(title: ^String.History.delete) { _ in
                    self?.handleContextAction(.delete, item: item)
                }
            ]
            if item.type == .pdf {
                children.append(UIAction(title: ^String.History.share) { _ in
                    self?.handleContextAction(.share, item: item)
                })
            } else {
                children.append(UIAction(title: ^String.History.copy) { _ in
                    self?.handleContextAction(.copy, item: item)
                })
                let shareMenuItems = [
                    UIAction(title: ^String.ScanResult.shareAsImage, image: AppImage.photo.uiImageWith(tint: .appOrange), handler: { _ in
                        self?.handleContextAction(.shareAsImage, item: item)
                    }),
                    UIAction(title: ^String.ScanResult.shareAsText, image: AppImage.commonDocImage.uiImageWith(tint: .appOrange), handler: { _ in
                        self?.handleContextAction(.shareAsText, item: item)
                    })
                ]
                let shareMenu = UIMenu(title: ^String.History.share, children: shareMenuItems)
                children.append(shareMenu)
            }

            let menu = UIMenu(title: "", children: children)
            return menu
        }
    }

}

class HistoryPresenter {

    private weak var controller: UIViewController?
    private(set) var layoutPresenter: HistoryLayoutPresenterProtocol!
    private var searchQuery = "" {
        didSet {
            reloadItems()
        }
    }

    private(set) var itemsFilter: ScanModel.ScanType? {
        didSet {
            reloadItems()
        }
    }

    private var selectedItems: [ScanModel] = [] {
        didSet {
            (layoutPresenter as? HistoryGridPresenter)?.selectedItems = selectedItems
        }
    }

    private let toolbarRemoveBtn = UIBarButtonItem(image: .commonRemove)
    let toolbar = UIToolbar(frame: .init(origin: .zero, size: CGSize(width: Constants.screenWidth, height: 44)))

    init(controller: UIViewController, layout: HistoryViewController.PresentationMode) {
        self.controller = controller
        handleLayoutChange(to: layout)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleItemsUpdate),
            name: ScannedItemsManager.itemsUpdateNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func handleSearch(query: String) {
        searchQuery = query
    }

    func handleFilter(by filter: ScanModel.ScanType?) {
        itemsFilter = filter
    }

    func handleLayoutChange(to layout: HistoryViewController.PresentationMode) {
        guard let controller = controller else {
            return
        }
        controller.view.subviews.forEach { $0.removeFromSuperview() }
        layoutPresenter = layout == .list ? HistoryListPresenter() : HistoryGridPresenter()

        layoutPresenter.delegate = self

        let contentView = layoutPresenter.getView()
        controller.view.addSubview(contentView)
        contentView.edgesToSuperview(usingSafeArea: true)

        controller.view.addSubview(toolbar)
        toolbar.isHidden = true
        toolbar.edgesToSuperview(excluding: .top, usingSafeArea: true)
        toolbarRemoveBtn.addTarget(self, action: #selector(toolbarRemovePressed))
        toolbarRemoveBtn.isEnabled = false
        toolbar.setItems([toolbarRemoveBtn], animated: true)
        setupEditMode(false)
        reloadItems()
    }

    func setupEditMode(_ enabled: Bool) {
        layoutPresenter.isEditing = enabled
        toolbar.isHidden = !enabled
        let viewController = controller as? HistoryViewController
        viewController?.filterButton.isEnabled = !enabled
        viewController?.filterButton.setImage(AppImage.filterImage.uiImageWith(tint: enabled ? .appSystemGray4 : .appOrange), for: .normal)
        viewController?.searchController.searchBar.isUserInteractionEnabled = !enabled
        if !enabled {
            selectedItems = []
        }
    }

    // MARK: - Helpers

    private func allowedItemTypes() -> [ScanModel.ScanType] {
        if let filter = itemsFilter {
            return [filter]
        }
        return [.qr, .barcode, .pdf]
    }

    private func reloadItems() {
        // show the newest items at the top
        var filteredItems = ScannedItemsManager.shared.items.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        // filter by type
        let allowedTypes: [ScanModel.ScanType] = allowedItemTypes()
        filteredItems = filteredItems.filter { allowedTypes.contains($0.type) }
        // filter by query
        if !searchQuery.isEmpty {
            filteredItems = filteredItems.filter { $0.data.lowercased().contains(searchQuery.lowercased()) }
        }
        layoutPresenter.showItems(filteredItems)
        selectedItems = []
    }

    private func selectItemInEdintingMode(item: ScanModel) {
        if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
        toolbarRemoveBtn.isEnabled = selectedItems.count >= 1
    }

    // MARK: - Handlers

    @objc private func handleItemsUpdate() {
        reloadItems()
        setupEditMode(false)
    }

    @objc private func toolbarRemovePressed() {
        controller?.showDeleteConfirmationAlert { [weak self] result in
            // if result = false don't remove items
            guard let welf = self, result else {
                return
            }
            ScannedItemsManager.shared.removeItemsBunch(welf.selectedItems) { [weak self] in
                self?.selectedItems.removeAll()
            }
        }
    }

}

extension HistoryPresenter: HistoryLayoutPresenterDelegate {

    func didSelectCell(with item: ScanModel) {
        guard layoutPresenter.isEditing else {
            controller?.showResultViewController(item)
            return
        }
        selectItemInEdintingMode(item: item)
        print("selectedItems - ", selectedItems.count)
    }

    func didDeselectCell(with item: ScanModel) {
        guard layoutPresenter.isEditing else {
            return
        }
        selectItemInEdintingMode(item: item)
        print("selectedItems - ", selectedItems.count)
    }

    func removeItem(_ item: ScanModel) {
        let completion: (Error?) -> Void = { [weak self] error in
            if error == nil {
                self?.reloadItems()
            } else {
                self?.controller?.view.makeToast(error?.localizedDescription)
            }
        }

        controller?.showDeleteConfirmationAlert { confirmed in
            guard confirmed else {
                return
            }
            if item.type == .pdf {
                ScannedItemsManager.shared.removePDF(item, completion: completion)
            } else {
                ScannedItemsManager.shared.removeItem(item, completion: completion)
            }
        }
    }

    func handleContextAction(_ action: ScanContextMenuAction, item: ScanModel) {
        switch action {
        case .share:
            guard let document = PDFDocument(url: URL.pdfDocument(name: item.data))?.dataRepresentation() else {
                return
            }
            showActivityController(activityItems: [document])
        case .shareAsImage:
            guard let image = UIImage.barcode(data: item.data, type: item.dataFormat, size: .init(width: 1_000, height: 1_000)) else {
                return
            }
            showActivityController(activityItems: [image])
        case .shareAsText:
            showActivityController(activityItems: [item.data])
        case .delete:
            removeItem(item)
        case .copy:
            UIPasteboard.general.string = item.data
            let message = String.ScanResult.clipboardTitle.format(^String.ScanResult.code)
            controller?.view.makeToast(message)
        }
    }

    private func showActivityController(activityItems: [Any]) {
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller?.present(viewController, animated: true)
    }

}
