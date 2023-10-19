//
//  ProductScannerPresenter.swift
//  smm-barcode
//
//  Created by Daniil on 10.04.2023.
//

import PDFKit
import UIKit

class ProductScannerPresenter: NSObject {

    private weak var controller: ProductScannerViewController?
    private let model = EdamamApiProvider()
    private let hintsScrollView = UIScrollViewWithStack(axis: .horizontal, spacing: 6)
    private var emptyView = UIView()
    private let tableView = ViewsFactory.defaultTableView(style: .insetGrouped)
    private(set) var sections: [(date: Date, items: [ScanModel])] = []

    init(controller: ProductScannerViewController) {
        super.init()
        self.controller = controller
        setLayout()
        prepareData()
    }

    func prepareData() {
        // show the newest items at the top
        var filteredItems = ScannedItemsManager.shared.items.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        // filter by type
        filteredItems = filteredItems.filter { $0.type == .product }
        var groupedItems: [Date: [ScanModel]] = [:]
        filteredItems.forEach { item in
            let date = item.date.dateExceptTime
            let items = (groupedItems[date] ?? []) + [item]
            groupedItems[date] = items
        }
        sections = groupedItems.map { ($0, $1) }.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        tableView.reloadData()
        changeVisibilityOfSubViews(showHintsView: false)
    }

    func setLayout() {
        controller?.view.addSubview(tableView)
        tableView.edgesToSuperview(usingSafeArea: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.description())
        setupEmptyView()

        controller?.view.addSubview(hintsScrollView)
        hintsScrollView.edgesToSuperview(excluding: .bottom, insets: .top(10), usingSafeArea: true)
        hintsScrollView.setupMargins(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
        hintsScrollView.showsHorizontalScrollIndicator = false
    }

    // MARK: - Helpers

    func updateHintsScrollView(titles: [String]) {
        hintsScrollView.stack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        titles.forEach {
            let button = ViewsFactory.defaultButton(color: .appClear, font: .semibold(15), titleColor: .appOrange)
            button.setTitle($0, for: .normal)
            button.addTarget(self, action: #selector(hintHandler(_:)), for: .touchDown)
            let color = UIColor(red: 0.898, green: 0.898, blue: 0.918, alpha: 1)
            let wrappedButton = button.wrap(horizontalInsets: 10, verticalInsets: 4)
            wrappedButton.backgroundColor = color
            wrappedButton.layer.cornerRadius = 6
            hintsScrollView.stack.addArrangedSubview(wrappedButton)
        }
    }

    func searchRequest(query: String) {
        if query.count >= 1 {
            model.getAutocomplete(for: query) { [weak self] result in
                switch result {
                case let .success(success):
                    self?.changeVisibilityOfSubViews(showHintsView: query.count >= 1)
                    self?.updateHintsScrollView(titles: success)
                    print(success)
                case let .failure(failure):
                    self?.controller?.view.makeToast(failure.localizedDescription)
                }
            }
        } else {
            changeVisibilityOfSubViews(showHintsView: query.count >= 1)
        }
    }

    private func setupEmptyView() {
        let title = ViewsFactory.defaultLabel(font: .bold(34), textColor: .appBlack, alignment: .center)
        title.text = ^String.Product.productScanner
        let subTitle = ViewsFactory.defaultLabel(font: .regular(17), textColor: .appSystemGray, alignment: .center, lines: 2)
        subTitle.text = ^String.Product.productScannerEmptyPreviewTitle
        let titlesStack = ViewsFactory.defaultStackView(axis: .vertical, spacing: 6, distribution: .fill)
        [title, subTitle].forEach {
            titlesStack.addArrangedSubview($0)
        }

        let button = ViewsFactory.defaultButton(radius: 14, font: .regular(20), height: 56)
        let attributes = NSAttributedString.stringWithImage(title: ^String.ButtonTitles.scanProduct, image: .barcode)
        button.setAttributedTitle(attributes, for: .normal)
        button.addTarget(self, action: #selector(scanProductHandler), for: .touchDown)

        let titlesWithButtonStack = ViewsFactory.defaultStackView(axis: .vertical, spacing: 12)
        [titlesStack, button].forEach {
            titlesWithButtonStack.addArrangedSubview($0)
        }

        let image = ViewsFactory.defaultImageView(image: AppImage.productScannerEmptyPreview.uiImage)
        image.size(CGSize(width: 77, height: 77))
        let mainStack = ViewsFactory.defaultStackView(axis: .vertical, spacing: 24)

        [image, titlesWithButtonStack].forEach {
            mainStack.addArrangedSubview($0)
        }

        let wrappedEmptyView = UIView()
        wrappedEmptyView.addSubview(mainStack)
        mainStack.horizontalToSuperview(insets: .horizontal(16))
        mainStack.topToSuperview(offset: 138)

        emptyView = wrappedEmptyView
        controller?.view.addSubview(emptyView)
        emptyView.edgesToSuperview(usingSafeArea: true)
    }

    private func changeVisibilityOfSubViews(showHintsView: Bool) {
        hintsScrollView.isHidden = !showHintsView
        [emptyView, tableView].forEach {
            $0.isHidden = showHintsView
        }

        if showHintsView == false {
            let isEmpty = sections.count == 0
            emptyView.isHidden = !isEmpty
            tableView.isHidden = isEmpty
        }
    }

    private func showScanResultViewFromHint(name: String) {
        let resultController = ProductResultCardViewController()
        let presenter = ProductResultPresenter(controller: resultController, dataOrigin: .byName(name: name))
        presenter.codeInfoCardPresenter = nil // from hint
        presenter.foodInfoPresenters = [
            CommonFoodInfoCardPresenter(controller: resultController),
            NutrientsFoodInfoCardPresenter(controller: resultController),
            MicronutrientsFoodInfoCardPresenter(controller: resultController)
        ]
        resultController.presenter = presenter
        controller?.presentFullScreenController(controller: resultController)
    }

    private func showProduct(item: ScanModel) {
        controller?.showResultViewController(item)
    }

    private func startDataloading() {}

    func removeItem(_ item: ScanModel) {
        let completion: (Error?) -> Void = { [weak self] error in
            if error == nil {
                self?.prepareData()
            } else {
                self?.controller?.view.makeToast(error?.localizedDescription)
            }
        }

        controller?.showDeleteConfirmationAlert { confirmed in
            guard confirmed else {
                return
            }
            ScannedItemsManager.shared.removeItem(item, completion: completion)
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

    // MARK: - Handlers

    @objc private func hintHandler(_ sender: UIButton) {
        guard let name = sender.titleLabel?.text else {
            return
        }
        showScanResultViewFromHint(name: name)
    }

    @objc func scanProductHandler() {
        if let scanProductHandler = controller?.scanProductHandler {
            scanProductHandler()
            controller?.dismiss(animated: true)
        }
    }

}

extension ProductScannerPresenter: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = MomentJS.calendar(sections[section].date) ?? ""
        return ViewsFactory.defaultHeaderView(text: title.uppercased())
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.description()) else {
            return UITableViewCell()
        }

        let model = sections[indexPath.section].items[indexPath.row]
        (cell as? HistoryTableViewCell)?.setData(item: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section].items[indexPath.row]
        showProduct(item: model)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = sections[indexPath.section].items[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            var children: [UIMenuElement] = [
                UIAction(title: ^String.History.delete) { _ in
                    self?.handleContextAction(.delete, item: item)
                },
                UIAction(title: ^String.History.copy) { _ in
                    self?.handleContextAction(.copy, item: item)
                }
            ]

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

            let menu = UIMenu(title: "", children: children)
            return menu
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = sections[indexPath.section].items[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: ^String.History.delete) { [weak self] _, _, _ in
            self?.removeItem(item)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

}
