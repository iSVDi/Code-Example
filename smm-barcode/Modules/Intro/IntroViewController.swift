//
//  IntroViewController.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

class IntroViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = ViewsFactory.defaultScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private let continueButton = ViewsFactory.continueButton()

    private var slides: [UIView] = []
    private var subscriptionSlideIndex: Int {
        return slides.count - 1
    }

    private let helpUsSlideIndex = 2
    private var currentSlideIndex = 0 {
        didSet {
            isTrialSlide = currentSlideIndex == slides.count - 1
        }
    }

    private var isTrialSlide = false

    private var unlimitedAccessPresenter: BuyUnlimitedAccessPresenter!
    private var privacyAndTosView: UIView!

    required init(completion: @escaping (() -> Void)) {
        super.init(nibName: nil, bundle: nil)
        unlimitedAccessPresenter = BuyUnlimitedAccessPresenter(controller: self) {
            completion()
        }
        privacyAndTosView = unlimitedAccessPresenter.viewHelper.createPrivacyAndTosView()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitles()
        setupViews()
        setupLayout()
        setupHandlers()
        updateSlideState()
        unlimitedAccessPresenter.handleViewDidLoad()
    }

    // MARK: - Helpers

    private func setTitles() {
        continueButton.setTitle(^String.ButtonTitles.continueButtonTitle, for: .normal)
    }

    private func setupViews() {
        view.backgroundColor = .appWhite
        slides = IntroSlidesHelper().createSlides()
        slides.append(unlimitedAccessPresenter.viewHelper.trialSlideView)
    }

    private func setupLayout() {
        let stackView = ViewsFactory.defaultStackView(axis: .horizontal)
        scrollView.addSubview(stackView)
        stackView.edgesToSuperview()
        slides.forEach { slide in
            stackView.addArrangedSubview(slide)
            slide.size(to: scrollView)
        }
        unlimitedAccessPresenter.viewHelper.defaultLayoutInView(
            view,
            slidesView: scrollView,
            button: continueButton,
            privacyView: privacyAndTosView
        )
    }

    private func setupHandlers() {
        scrollView.delegate = self
        continueButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
    }

    private func updateSlideState() {
        let notTrialSlide = !isTrialSlide
        navigationController?.setNavigationBarHidden(notTrialSlide, animated: true)
        privacyAndTosView.isHidden = notTrialSlide
        unlimitedAccessPresenter.showsErrors = isTrialSlide
    }

    private func scrollToNextSlide() {
        var nextSlideFrame = scrollView.frame
        nextSlideFrame.origin.x = nextSlideFrame.size.width * CGFloat(currentSlideIndex + 1)
        scrollView.scrollRectToVisible(nextSlideFrame, animated: true)
    }

    // MARK: - Handlers

    @objc private func continueButtonPressed() {
        if isTrialSlide {
            unlimitedAccessPresenter.continueButtonPressed()
        } else {
            switch currentSlideIndex {
            case helpUsSlideIndex:
                AppTrackingPermission.requestIDFA { [weak self] in
                    self?.scrollToNextSlide()
                }
            default:
                scrollToNextSlide()
            }
        }
    }

}

// MARK: - Scroll View Delegate

extension IntroViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentSlideIndex = Int(round(scrollView.contentOffset.x / max(1, scrollView.frame.width)))
        updateSlideState()
    }

}
