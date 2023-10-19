//
//  BarcodeSearchCardPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 03.04.2023.
//

import Foundation
import UIKit

private enum SearcherType: Int, CaseIterable {
    case google = 0
    case amazon = 1
    case aliexpress = 2
    case ebay = 3

    var title: String? {
        switch self {
        case .google:
            return ^String.Search.google
        case .amazon:
            return ^String.Search.amazon
        case .aliexpress:
            return ^String.Search.aliexpress
        case .ebay:
            return ^String.Search.ebay
        }
    }

    var icon: UIImage? {
        switch self {
        case .google:
            return AppImage.google.uiImage
        case .amazon:
            return AppImage.amazon.uiImage
        case .aliexpress:
            return AppImage.aliexpress.uiImage
        case .ebay:
            return AppImage.ebay.uiImage
        }
    }

    func link(for query: String) -> URL? {
        var path = ""
        switch self {
        case .google:
            path = "https://www.google.ru/search?q=\(query)"
        case .amazon:
            path = "https://www.amazon.com/s?k=\(query)"
        case .aliexpress:
            path = "https://aliexpress.ru/wholesale?SearchText=\(query)"
        case .ebay:
            path = "https://www.ebay.com/sch/i.html?_nkw=\(query)"
        }
        return URL(string: path)
    }
}

class BarcodeSearchCardPresenter: AbstractCardPresenter {

    private var barcode: String!

    convenience init(barcode: String, controller: UIViewController) {
        self.init(controller: controller)
        self.barcode = barcode
    }

    override func cardView() -> UIView {
        let parentStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 3)

        let cells = SearcherType.allCases.map { searchType in
            let mainHStack = ViewsFactory.defaultStackView(spacing: 171)
            let hStack = ViewsFactory.defaultStackView(spacing: 14)
            let label = ViewsFactory.defaultLabel()
            label.text = searchType.title
            let imageView = ViewsFactory.defaultImageView(image: searchType.icon, contentMode: .scaleToFill)
            imageView.size(CGSize(width: 28, height: 28), priority: .defaultHigh)

            [imageView, label].forEach {
                hStack.addArrangedSubview($0)
            }

            let accessoryImageView = ViewsFactory.defaultImageView(image: AppImage.commonChevronRight.uiImageWith(font: .regular(21), tint: .appSystemGray4))
            accessoryImageView.size(CGSize(width: 16, height: 25))

            [hStack, accessoryImageView].forEach {
                mainHStack.addArrangedSubview($0)
            }

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchHandler(_:)))
            mainHStack.addGestureRecognizer(gestureRecognizer)
            mainHStack.tag = searchType.rawValue
            return mainHStack.wrap(verticalInsets: 19)
        }

        let cellsWithSeparatorsHStack = ViewsFactory.defaultStackView(axis: .vertical)
        cells.forEach {
            cellsWithSeparatorsHStack.addArrangedSubview($0)
            cellsWithSeparatorsHStack.addArrangedSubview(getSeparatorView())
        }

        let label = ViewsFactory.defaultLabel(font: .semibold(17), textColor: .appBlack)
        label.text = ^String.Search.searchTitle
        [label, ViewsFactory.wrapView(cellsWithSeparatorsHStack)].forEach { parentStackView.addArrangedSubview($0) }

        return parentStackView
    }

    @objc private func searchHandler(_ handler: UITapGestureRecognizer) {
        guard let tag = handler.view?.tag,
              let searcherType = SearcherType(rawValue: tag),
              let url = searcherType.link(for: barcode) else {
            return
        }
        controller?.openLinkURL(url)
    }

}
