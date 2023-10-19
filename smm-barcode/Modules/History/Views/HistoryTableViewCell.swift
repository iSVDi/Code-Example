//
//  HistoryTableViewCell.swift
//  smm-barcode
//
//  Created by Daniil on 21.03.2023.
//

import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {

    private let viewImage = ViewsFactory.defaultImageView(image: AppImage.settingsDocSquare.uiImage)
    private let titleLabel = ViewsFactory.defaultLabel(font: .regular(17), textColor: .appBlack, lines: 0)
    private let subtitleLabel = ViewsFactory.defaultLabel(font: .medium(15), textColor: .appGray, lines: 0)
    // we keep a url to the document so that in case of reusing the cell, ignore the thumbnail generation completion block
    private var thumbnailDocumentUrl: URL?

    // MARK: - Interface

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailDocumentUrl = nil
        viewImage.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func setData(item: ScanModel) {
        titleLabel.text = item.data
        let subTitle = item.type == .product ? ScanModel.ScanType.barcode.rawValue : item.type.rawValue
        subtitleLabel.text = subTitle == ScanModel.ScanType.barcode.rawValue ? subTitle.capitalizeFirstLetter() : subTitle.uppercased()

        if item.type == .pdf {
            // set preview placeholder
            viewImage.image = AppImage.pdfPreview.uiImage
            // generate thumbnail of document
            let url = URL.pdfDocument(name: item.data)
            thumbnailDocumentUrl = url
            ThumbnailHelper.shared.thumbnail(of: url, size: HistoryCellConstants.imageViewSize) { [weak self] documentUrl, image in
                // ensure the cell has not been reused
                guard documentUrl == self?.thumbnailDocumentUrl else {
                    return
                }
                self?.viewImage.image = image
            }
        } else {
            viewImage.image = UIImage.barcode(
                data: item.data,
                type: item.dataFormat,
                size: item.type == .barcode ? .init(width: 80, height: 80 / 3.278) : .init(width: 80, height: 80)
            )
        }
    }

    // MARK: - Helpers

    private func commonInit() {
        let titlesStack = ViewsFactory.defaultStackView(axis: .vertical, alignment: .leading)
        [titleLabel, subtitleLabel].forEach {
            titlesStack.addArrangedSubview($0)
        }
        let mainStack = ViewsFactory.defaultStackView(spacing: 13, alignment: .center)
        [viewImage, titlesStack].forEach {
            mainStack.addArrangedSubview($0)
        }

        viewImage.size(CGSize(width: 28, height: 28))
        let view = mainStack.wrap()
        contentView.addSubview(view)
        view.edgesToSuperview()

        tintColor = .appOrange
    }

}
