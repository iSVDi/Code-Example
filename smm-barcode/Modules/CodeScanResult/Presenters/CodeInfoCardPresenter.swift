//
//  CodeInfoCardPresenter.swift
//  smm-barcode
//
//  Created by Daniil on 03.04.2023.
//

import Foundation
import UIKit

enum CardInfo {
    case qrInfo
    case barcodeInfo

    fileprivate var ratio: Double {
        switch self {
        case .qrInfo:
            return 1
        case .barcodeInfo:
            return 318.0 / 97.0
        }
    }

    fileprivate var imageSize: CGSize {
        let ratio = self.ratio
        let imageWidth = Constants.screenWidth
        let imageHeight = imageWidth / ratio
        let size: CGSize = .init(width: imageWidth, height: imageHeight)
        return size
    }

    fileprivate func getScannedResult(model: ScanModel) -> String {
        switch self {
        case .qrInfo:
            return model.type.rawValue.uppercased()
        case .barcodeInfo:
            return model.type.rawValue.capitalizeFirstLetter()
        }
    }

    fileprivate func getElementTitle(model: ScanModel) -> String {
        switch self {
        case .qrInfo:
            if getIsDataUrl(model: model) {
                return ^String.ScanResult.website
            }
            return ^String.ScanResult.text
        case .barcodeInfo:
            return model.element
        }
    }

    fileprivate func getIsDataUrl(model: ScanModel) -> Bool {
        if let url = URL(string: model.data) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    fileprivate var dataTitle: String {
        switch self {
        case .qrInfo:
            return ^String.ScanResult.data
        case .barcodeInfo:
            return ^String.ScanResult.code
        }
    }
}

class CodeInfoCardPresenter: AbstractCardPresenter {

    private var model: ScanModel!
    private(set) var cardInfo: CardInfo = .qrInfo

    convenience init(model: ScanModel, controller: UIViewController, cardInfo: CardInfo) {
        self.init(controller: controller)
        self.model = model
        self.cardInfo = cardInfo
    }

    override func cardView() -> UIView {
        let parentStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 3)

        let image = UIImage.barcode(data: model.data, type: model.dataFormat, size: cardInfo.imageSize)
        let imageView = ViewsFactory.defaultImageView(image: image)
        imageView.aspectRatio(cardInfo.ratio)

        let cellsData: [(titile: String?, subtitile: String?)] = [
            (^String.ScanResult.scannedResultTitle, cardInfo.getScannedResult(model: model)),
            (^String.ScanResult.element, cardInfo.getElementTitle(model: model))
        ]

        var cells: [UIView] = cellsData.map { title, subtitle in
            let hStack = ViewsFactory.defaultStackView(spacing: 89)
            let label = ViewsFactory.defaultLabel()
            label.width(min: 34, max: 228, priority: .defaultHigh, isActive: true)
            label.text = title
            let subLabel = ViewsFactory.defaultLabel(textColor: .appOrange, alignment: .right)
            subLabel.width(min: 24, max: 127, priority: .defaultLow, isActive: true)
            subLabel.text = subtitle
            [label, subLabel].forEach {
                hStack.addArrangedSubview($0)
            }
            return hStack.wrap()
        }

        var dataCell: UIView {
            let hStack = ViewsFactory.defaultStackView(spacing: 87)
            let dataTitleLabel = ViewsFactory.defaultLabel()
            dataTitleLabel.text = cardInfo.dataTitle

            [dataTitleLabel, getAccessoryView()].forEach {
                hStack.addArrangedSubview($0)
            }

            return hStack.wrap(verticalInsets: 19)
        }
        cells.append(dataCell)

        let vStack = ViewsFactory.defaultStackView(axis: .vertical)
        vStack.backgroundColor = .appWhite
        vStack.addArrangedSubview(imageView.wrap())
        cells.forEach {
            vStack.addArrangedSubview(getSeparatorView())
            vStack.addArrangedSubview($0)
        }

        let label = ViewsFactory.defaultLabel(font: .semibold(17), textColor: .appBlack)
        label.text = ^String.ScanResult.codeInformation
        [label, ViewsFactory.wrapView(vStack)].forEach { parentStackView.addArrangedSubview($0) }

        return parentStackView
    }

    private func getAccessoryView() -> UIView {
        let hStack = ViewsFactory.defaultStackView(spacing: 16)
        let dataLabel = ViewsFactory.defaultLabel(textColor: .appOrange, alignment: .right)
        dataLabel.width(min: 24, max: 127, priority: .defaultLow, isActive: true)
        dataLabel.text = model.data

        let button = ViewsFactory.defaultButton(color: .appClear)
        let image = cardInfo.getIsDataUrl(model: model) ? AppImage.linkArrowImage.uiImageWith(tint: .appOrange) : AppImage.commonCopy.uiImageWith(tint: .appOrange)
        let selector = cardInfo.getIsDataUrl(model: model) ? #selector(showLink) : #selector(toolBarCopyHandler)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: selector, for: .touchDown)
        button.size(CGSize(width: 20, height: 20), priority: .defaultHigh)

        let separatorLine = getSeparatorView(axis: .vertical)
        [dataLabel, separatorLine, button].forEach {
            hStack.addArrangedSubview($0)
        }

        return hStack
    }

    @objc private func toolBarCopyHandler() {
        UIPasteboard.general.string = model.data
        let message = String.ScanResult.clipboardTitle.format(^String.ScanResult.code)
        controller?.view.makeToast(message)
    }

    @objc private func showLink() {
        guard let url = URL(string: model.data) else {
            return
        }
        controller?.openLinkURL(url)
    }

}
