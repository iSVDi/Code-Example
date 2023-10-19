//
//  CardViewController.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 02.04.2023.
//

import Foundation
import TinyConstraints
import UIKit

private enum CardViewControllerConstants {
    static let cardSpace = UIOffset(horizontal: 16, vertical: 3)
}

class CardViewController: UIViewController {

    var toolbarPresenter: ScanResultToolbarPresenter!
    private let scrollView = ViewsFactory.defaultScrollView()
    private let stackView = ViewsFactory.defaultStackView(axis: .vertical)

    override func loadView() {
        super.loadView()
        setupScrollView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDismissLeftBarButtonItem()
        view.backgroundColor = .appLightGray3
        setupLayout()
        showCardViews()
    }

    func getPresenters() -> [AbstractCardPresenter] {
        fatalError("not implemented")
    }

    // MARK: - Helpers

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        scrollView.bottomToSuperview(offset: -44)
    }

    private func setupLayout() {
        let space = CardViewControllerConstants.cardSpace
        scrollView.addSubview(stackView)
        stackView.spacing = space.vertical
        stackView.edges(to: scrollView, insets: .init(
            top: space.vertical,
            left: space.horizontal,
            bottom: space.vertical,
            right: space.horizontal
        ))
        stackView.centerXToSuperview()
        if let toolbarPresenter = toolbarPresenter {
            let toolbar = toolbarPresenter.buildToolbarView()
            view.addSubview(toolbar)
            toolbar.edgesToSuperview(excluding: .top, usingSafeArea: true)
        }
    }

    private func showCardViews() {
        let views = getPresenters().map { return $0.cardView() }
        views.forEach {
            stackView.addArrangedSubview($0)
        }
    }

}

class ScanResultCardViewController: CardViewController {

    var staticPresenters: [AbstractCardPresenter] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ^String.Scan.scanResult
    }

    override func getPresenters() -> [AbstractCardPresenter] {
        return staticPresenters
    }

}

class ProductResultPresenter {

    enum DataOrigin {
        case byName(name: String)
        case byBarcode(barcode: String)
    }

    static let itemsUpdateNotification = Notification.Name("ProductResultSendRequestAgain")
    private weak var controller: UIViewController?
    var codeInfoCardPresenter: CodeInfoCardPresenter?
    var foodInfoPresenters: [AbstractFoodInfoCardPresenter] = []
    private let dataOrigin: DataOrigin
    let provider = EdamamApiProvider()

    init(controller: UIViewController, dataOrigin: DataOrigin) {
        self.controller = controller
        self.dataOrigin = dataOrigin
    }

    func handleViewDidLoad() {
        loadFoodInfo()
        foodInfoPresenters.forEach {
            $0.foodCardView.tryAgainButton.addTarget(self, action: #selector(tryAgainButtonPressed), for: .touchUpInside)
        }
    }

    func getPresenters() -> [AbstractCardPresenter] {
        return ([codeInfoCardPresenter] + foodInfoPresenters).compactMap { $0 }
    }

    // MARK: - Handlers

    @objc private func tryAgainButtonPressed() {
        loadFoodInfo()
    }

    private func loadFoodInfo() {
        foodInfoPresenters.forEach {
            $0.cardView().isHidden = false
            $0.showLoadingState()
        }
        switch dataOrigin {
        case let .byName(name: name):
            provider.loadFoodInfo(name: name) { [weak self] result in
                switch result {
                case let .success(success):
                    let item = success?.hints.first(where: { $0.food.label.lowercased() == name }) ?? success?.hints.first
                    self?.loadNutrients(for: item)
                case let .failure(error):
                    self?.completeLoading(with: error)
                }
            }
        case let .byBarcode(barcode: barcode):
            provider.loadFoodInfo(barcode: barcode) { [weak self] result in
                switch result {
                case let .success(success):
                    let item = success?.hints.first
                    self?.loadNutrients(for: item)
                case let .failure(error):
                    self?.completeLoading(with: error)
                }
            }
        }
    }

    func loadNutrients(for foodHint: EdamamHintFood?) {
        guard let foodId = foodHint?.food.foodId,
              let measure = foodHint?.measures.first else {
            completeLoading(foodHint: foodHint, nutrientsInfo: nil)
            return
        }
        provider.loadNutrients(foodId: foodId, measureURI: measure.uri) { [weak self] result in
            switch result {
            case let .success(nutrients):
                if let nutrients = nutrients {
                    self?.completeLoading(foodHint: foodHint, nutrientsInfo: (measure, nutrients))
                } else {
                    self?.completeLoading(foodHint: foodHint, nutrientsInfo: nil)
                }
            case let .failure(error):
                self?.completeLoading(with: error)
            }
        }
    }

    func completeLoading(foodHint: EdamamHintFood?, nutrientsInfo: (measure: EdamamMeasure, nutrients: EdamamNutrients)?) {
        foodInfoPresenters.forEach { $0.showData(food: foodHint?.food, nutrientsInfo: nutrientsInfo) }
    }

    func completeLoading(with error: Error?) {
        foodInfoPresenters.enumerated().forEach {
            // hide all presenters except first one
            $1.cardView().isHidden = $0 != 0
            // show error state with retry button
            $1.showError()
        }
    }

}

class ProductResultCardViewController: CardViewController {

    var presenter: ProductResultPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ^String.Product.foodInfo
        presenter.handleViewDidLoad()
    }

    override func getPresenters() -> [AbstractCardPresenter] {
        presenter.getPresenters()
    }

}
