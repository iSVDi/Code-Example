//
//  HistoryCollectionViewCell.swift
//  smm-video-editor
//
//  Created by Timur Pervov on 27.01.2022.
//

import UIKit

struct HistoryCellConstants {
    static let imageViewSize = CGSize(width: 80, height: 80)
    static let imageSpacing: CGFloat = 12
    static let labelHeight: CGFloat = 32
    static let labelsSpacing: CGFloat = 2
    static let subLabelHeight: CGFloat = 16
    static let cellHeight = imageViewSize.height + imageSpacing + labelHeight + subLabelHeight + labelsSpacing
}

class HistoryCollectionViewCell: UICollectionViewCell {

    private let imageView = ViewsFactory.defaultImageView()
    private let titleLabel = ViewsFactory.defaultLabel(font: .medium(13), alignment: .center, lines: 2)
    private let subtitleLabel = ViewsFactory.defaultLabel(font: .medium(13), textColor: .appGray)
    private let emptyLabel = ViewsFactory.defaultLabel()
    private let selectStateImage = ViewsFactory.defaultImageView(image: AppImage.trialCheckmark.uiImage)
    // we keep a url to the document so that in case of reusing the cell, ignore the thumbnail generation completion block
    private var thumbnailDocumentUrl: URL?

    // MARK: - Interface

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailDocumentUrl = nil
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        emptyLabel.text = nil
        selectStateImage.isHidden = true
    }

    func update(item: ScanModel, selectionState: Bool) {
        titleLabel.text = item.data
        let subTitle = item.type == .product ? ScanModel.ScanType.barcode.rawValue : item.type.rawValue
        subtitleLabel.text = subTitle == ScanModel.ScanType.barcode.rawValue ? subTitle.capitalizeFirstLetter() : subTitle.uppercased()
        emptyLabel.text = "\n"
        selectStateImage.isHidden = !selectionState

        if item.type == .pdf {
            // set preview placeholder
            imageView.image = AppImage.pdfPreview.uiImage
            // generate thumbnail of document
            let url = URL.pdfDocument(name: item.data)
            thumbnailDocumentUrl = url
            ThumbnailHelper.shared.thumbnail(of: url, size: HistoryCellConstants.imageViewSize) { [weak self] documentUrl, image in
                // ensure the cell has not been reused
                guard documentUrl == self?.thumbnailDocumentUrl else {
                    return
                }
                self?.imageView.image = image
            }
        } else {
            imageView.image = UIImage.barcode(
                data: item.data,
                type: item.dataFormat,
                size: item.type == .barcode ? .init(width: 80, height: 80 / 3.278) : .init(width: 80, height: 80)
            )
        }
    }

    func toggleSelection() {
        selectStateImage.isHidden.toggle()
    }

    // MARK: - Helpers

    private func commonInit() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6

        let titlesStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: HistoryCellConstants.labelsSpacing, alignment: .center)
        [titleLabel, subtitleLabel, emptyLabel].forEach {
            titlesStackView.addArrangedSubview($0)
        }
        emptyLabel.setHugging(.required, for: .vertical)

        let parentStackView = ViewsFactory.defaultStackView(
            axis: .vertical,
            spacing: HistoryCellConstants.imageSpacing,
            alignment: .center,
            margins: .horizontal(6)
        )
        [imageView, titlesStackView].forEach { parentStackView.addArrangedSubview($0) }
        imageView.size(HistoryCellConstants.imageViewSize)
        contentView.addSubview(parentStackView)
        parentStackView.edgesToSuperview()

        contentView.addSubview(selectStateImage)
        selectStateImage.size(CGSize(width: 10, height: 10))
        selectStateImage.isHidden = true
        selectStateImage.rightToSuperview(offset: -5)
        selectStateImage.bottomToSuperview()
    }

}
