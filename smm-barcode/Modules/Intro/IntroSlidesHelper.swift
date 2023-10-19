//
//  IntroSlidesHelper.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import TinyConstraints

struct IntroConstants {
    var iPadBottomBlockWidth: CGFloat { 343 }
    var horizontalInsets: TinyEdgeInsets { .horizontal(16) }
}

class IntroSlidesHelper {

    func createSlides() -> [UIView] {
        return [firstIntroSlide(), secondIntroSlide(), thirdIntroSlide()]
    }

    private func firstIntroSlide() -> UIView {
        let slide = IntroSlideView()
        let image = Constants.isIpad ? AppImage.introFirstSlideIpad : .introFirstSlide
        slide.imageView.image = image.uiImage
        slide.titleLabel.text = ^String.Trial.paidPromoFeature1
        slide.descriptionLabel.text = ^String.Intro.introFirstSlideDescription
        return slide
    }

    private func secondIntroSlide() -> UIView {
        let slide = IntroSlideView()
        let image = Constants.isIpad ? AppImage.introSecondSlideIpad : .introSecondSlide
        slide.imageView.image = image.uiImage
        slide.titleLabel.text = ^String.Trial.paidPromoFeature2
        slide.descriptionLabel.text = ^String.Intro.introSecondSlideDescription
        return slide
    }

    private func thirdIntroSlide() -> UIView {
        let slide = IntroSlideView()
        let image = Constants.isIpad ? AppImage.introThirdSlideIpad : .introThirdSlide
        slide.imageView.image = image.uiImage
        slide.titleLabel.text = ^String.Trial.paidPromoFeature3
        slide.descriptionLabel.text = ^String.Intro.introThirdSlideDescription
        return slide
    }
    // Create more "get slides" methods for more screens. Do not forget add your assets into Assets.xcassets

}

private class IntroSlideView: UIView {

    let imageView: UIImageView = {
        let imageView = ViewsFactory.defaultImageView(contentMode: .scaleAspectFill)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18
        return imageView
    }()

    let titleLabel = ViewsFactory.defaultLabel(font: .bold(28), alignment: .center, adjustFont: true)
    let descriptionLabel = ViewsFactory.defaultLabel(textColor: .appSystemGray, alignment: .center, lines: 2, adjustFont: true)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Private Helpers

    private func commonInit() {
        let top = TinyEdgeInsets.top(Constants.statusBarHeight + 22)
        let horizontal = IntroConstants().horizontalInsets
        let bottom = TinyEdgeInsets.bottom(2)
        let stackView = ViewsFactory.defaultStackView(
            axis: .vertical,
            spacing: 10,
            margins: top + horizontal + bottom
        )
        stackView.insetsLayoutMarginsFromSafeArea = false

        [imageView, titleLabel, descriptionLabel].forEach { stackView.addArrangedSubview($0) }
        [titleLabel, descriptionLabel].forEach { $0.setHugging(.defaultHigh, for: .vertical) }
        imageView.setCompressionResistance(.defaultLow, for: .vertical)
        if Constants.isSmallScreen {
            stackView.setCustomSpacing(5, after: titleLabel)
        }

        addSubview(stackView)
        stackView.edgesToSuperview()
    }

}
