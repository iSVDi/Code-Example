//
//  SubscriptionPlanView.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import UIKit

class SubscriptionPlanView: UIView {

    private let parentHorizontalStackView = ViewsFactory.defaultStackView(alignment: .center, margins: .horizontal(19))
    private let titleLabel = ViewsFactory.defaultLabel(adjustFont: true)
    private let subtitleLabel = ViewsFactory.defaultLabel(adjustFont: true)

    private var priceLabel: UILabel?
    private var loadingIndicator: UIActivityIndicatorView?
    private var disclosureImageView: UIImageView?

    let viewButton = UIButton()
    private let isAlternative: Bool

    required init(isAlternative: Bool) {
        self.isAlternative = isAlternative
        super.init(frame: .zero)
        setupPlanView()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlanView() {
        height(Constants.isSmallScreen ? 50 : 60)
        layer.cornerRadius = 13

        let verticalStackView = ViewsFactory.defaultStackView(axis: .vertical, alignment: .leading)
        [titleLabel, subtitleLabel].forEach { verticalStackView.addArrangedSubview($0) }

        if isAlternative {
            titleLabel.font = .regular(17)
            subtitleLabel.font = .regular(15)
            let disclosureImageView = ViewsFactory.defaultImageView(image: AppImage.commonChevronRight.uiImage)
            disclosureImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            [verticalStackView, disclosureImageView].forEach {
                parentHorizontalStackView.addArrangedSubview($0)
            }
            self.disclosureImageView = disclosureImageView
        } else {
            titleLabel.font = .regular(13)
            subtitleLabel.font = .semibold(13)

            let separatorLine = ViewsFactory.separatorLine(color: .appSystemGray6)
            let priceLabel = ViewsFactory.defaultLabel(font: .semibold(13), adjustFont: true)
            let loadingIndicator = ViewsFactory.defaultActivityIndicator(style: .medium)

            separatorLine.height(32)

            [verticalStackView, separatorLine, priceLabel, loadingIndicator].forEach {
                parentHorizontalStackView.addArrangedSubview($0)
            }
            parentHorizontalStackView.distribution = .fill
            parentHorizontalStackView.setCustomSpacing(parentHorizontalStackView.layoutMargins.right, after: separatorLine)

            self.priceLabel = priceLabel
            self.loadingIndicator = loadingIndicator
        }
        [parentHorizontalStackView, viewButton].forEach {
            addSubview($0)
            $0.edgesToSuperview()
        }
        setSelectedState(false)
    }

    func setSelectedState(_ selected: Bool) {
        if isAlternative {
            backgroundColor = selected ? .appOrange : .appWhite
            titleLabel.textColor = selected ? .appWhite : .appBlack
            subtitleLabel.textColor = selected ? UIColor.appWhite : .appSystemGray
            disclosureImageView?.tintColor = subtitleLabel.textColor
        } else {
            layer.borderWidth = 2
            layer.borderColor = (selected ? UIColor.appOrange : .appSystemGray6).cgColor
        }
    }

    func setupWithInfo(_ plan: AppSubscriptionInfo) {
        if isAlternative {
            titleLabel.text = plan.alternativeTitle
            subtitleLabel.text = plan.alternativePriceString
        } else {
            titleLabel.text = plan.title
            subtitleLabel.text = plan.descriptionString
            priceLabel?.text = plan.priceString
            if priceLabel?.text?.isEmpty == false {
                loadingIndicator?.stopAnimating()
            } else {
                loadingIndicator?.startAnimating()
            }
        }
    }

}
