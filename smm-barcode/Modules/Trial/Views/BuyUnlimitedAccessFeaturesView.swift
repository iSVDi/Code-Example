//
//  BuyUnlimitedAccessFeaturesView.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import TinyConstraints

private class BuyUnlimitedAccessFeatureView: UIView {

    let imageView = ViewsFactory.defaultImageView()
    let titleLabel = ViewsFactory.defaultLabel(font: .regular(17))

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Helpers

    private func commonInit() {
        setupLayout()
    }

    private func setupLayout() {
        let labelsStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 2)
        labelsStackView.addArrangedSubview(titleLabel)
        let showDescription = Constants.screenHeight >= 736
        if showDescription {
            titleLabel.setHugging(.defaultHigh, for: .vertical)
        }

        imageView.width(23)
        let parentStackView = ViewsFactory.defaultStackView(spacing: 6, alignment: .center)
        [imageView, labelsStackView].forEach { parentStackView.addArrangedSubview($0) }

        addSubview(parentStackView)
        parentStackView.edgesToSuperview()
    }

}

class BuyUnlimitedAccessFeaturesView: UIView {

    private let firstFeatureView = BuyUnlimitedAccessFeatureView()
    private let secondFeatureView = BuyUnlimitedAccessFeatureView()
    private let thirdFeatureView = BuyUnlimitedAccessFeatureView()
    private let fourthFeatureView = BuyUnlimitedAccessFeatureView()

    required init(fromSettings: Bool = true) {
        super.init(frame: .zero)
        setTitles()
        setupViews()
        setupLayout(fromSettings: fromSettings)
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    private func setTitles() {
        firstFeatureView.titleLabel.text = ^String.Trial.paidPromoFeature1
        secondFeatureView.titleLabel.text = ^String.Trial.paidPromoFeature2
        thirdFeatureView.titleLabel.text = ^String.Trial.paidPromoFeature3
        fourthFeatureView.titleLabel.text = ^String.Trial.paidPromoNoAdsNoLimits
    }

    private func setupViews() {
        firstFeatureView.imageView.image = AppImage.trialCheckmark.uiImage
        secondFeatureView.imageView.image = AppImage.trialCheckmark.uiImage
        thirdFeatureView.imageView.image = AppImage.trialCheckmark.uiImage
        fourthFeatureView.imageView.image = AppImage.trialCheckmark.uiImage
    }

    private func imageAndLabelVerticalStack(title: String, image: UIImage?) -> UIStackView {
        let VStack = ViewsFactory.defaultStackView(axis: .vertical, spacing: 12, alignment: .center)
        let imageView = ViewsFactory.defaultImageView(image: image, contentMode: .scaleToFill)
        let label = ViewsFactory.defaultLabel(font: .regular(15), alignment: .center)
        label.text = title
        [imageView, label].forEach {
            VStack.addArrangedSubview($0)
        }
        return VStack
    }

    private func setupDeviceLayout(isIpad: Bool, spacing: CGFloat) {
        if isIpad {
            let mainStack = ViewsFactory.defaultStackView(spacing: 25, alignment: .center)
            let leftVStackTitle = (^String.ScannerMode.barcodeScanner).capitalized
            let rightVStackTitle = (^String.ScannerMode.productScanner).capitalized

            let leftVStack = imageAndLabelVerticalStack(title: leftVStackTitle, image: AppImage.featuresFirstSlideIpad.uiImage)
            let rightVStack = imageAndLabelVerticalStack(title: rightVStackTitle, image: AppImage.featuresSecondSlideIpad.uiImage)

            [leftVStack, rightVStack].forEach {
                mainStack.addArrangedSubview($0)
            }
            addSubview(mainStack)
            mainStack.edgesToSuperview()
        } else {
            let stackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: spacing, distribution: .fillEqually)
            [firstFeatureView, secondFeatureView, thirdFeatureView, fourthFeatureView].forEach {
                stackView.addArrangedSubview($0)
            }
            addSubview(stackView)
            stackView.edgesToSuperview()
        }
    }

    private func setupLayout(fromSettings: Bool) {
        let spacing: CGFloat = fromSettings ? 17 : 0
        setupDeviceLayout(isIpad: Constants.isIpad, spacing: spacing)
    }

}
