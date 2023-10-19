//
//  BuyUnlimitedAccessSlideView.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import TinyConstraints

class BuyUnlimitedAccessSlideView: UIView {

    private let headerImageView = ViewsFactory.defaultImageView(image: AppImage.launchscreenLogo.uiImage)
    private let headerLabel = ViewsFactory.defaultLabel(alignment: .center, lines: 2)
    private let featuresView = BuyUnlimitedAccessFeaturesView()
    let subscriptionsView = SubscriptionPlansView()

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
        setTitles()
        setupViews()
        setupLayout()
    }

    private func setTitles() {
        headerLabel.text = ^String.Trial.trialSlideHeaderTitle
    }

    private func setupViews() {
        let fontSize: CGFloat = Constants.isSmallScreen ? 22 : 34
        headerLabel.font = .bold(fontSize)
    }

    private func setupLayout() {
        let topInset = TinyEdgeInsets.top(Constants.isSmallScreen ? 32 : Constants.isIpad ? 147 : 72)
        let headerStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: Constants.isIpad ? 29 : 0, alignment: .center, margins: topInset)
        headerStackView.insetsLayoutMarginsFromSafeArea = false

        let size: CGFloat = Constants.isIpad ? 90 : 65
        headerImageView.size(CGSize(width: size, height: size))
        [headerImageView, headerLabel].forEach {
            headerStackView.addArrangedSubview($0)
            $0.setHugging(.defaultHigh, for: .vertical)
        }

        let mainStackView = ViewsFactory.defaultStackView(axis: .vertical, alignment: .center, margins: .uniform(32))
        mainStackView.addArrangedSubview(featuresView)

        let subscriptionsWrapper = UIView()
        subscriptionsWrapper.addSubview(subscriptionsView)
        let constants = IntroConstants()
        if Constants.isIpad {
            subscriptionsView.verticalToSuperview()
            subscriptionsView.centerXToSuperview()
            subscriptionsView.width(constants.iPadBottomBlockWidth)
        } else {
            subscriptionsView.edgesToSuperview(insets: constants.horizontalInsets)
        }

        let parentStackView = ViewsFactory.defaultStackView(axis: .vertical)
        [headerStackView, mainStackView, subscriptionsWrapper].forEach { parentStackView.addArrangedSubview($0) }
        addSubview(parentStackView)
        parentStackView.edgesToSuperview()
    }

}
