//
//  AbstractFoodInfoCardPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 05.04.2023.
//

import Foundation
import TinyConstraints
import UIKit

class FoodInfoCardView: UIView {

    let titleLabel = ViewsFactory.defaultLabel(font: .semibold(17), textColor: .appBlack)
    private let stackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 3)
    let tryAgainButton = ViewsFactory.defaultButton(radius: 14)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(stackView)
        stackView.edgesToSuperview()
        let spacer = UIView()
        spacer.backgroundColor = .appWhite
        spacer.height(50)
        [titleLabel, ViewsFactory.wrapView(spacer)].forEach { stackView.addArrangedSubview($0) }
    }

    func showLoadingState() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.color = .black
        loadingIndicator.startAnimating()
        let spacer = UIView()
        spacer.backgroundColor = .appWhite
        spacer.height(50)
        spacer.addSubview(loadingIndicator)
        loadingIndicator.centerInSuperview()
        [titleLabel, ViewsFactory.wrapView(spacer)].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    func showData(_ data: [(String, String)]) {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        let cells: [UIView] = data.map { title, subtitle in
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

        let vStack = ViewsFactory.defaultStackView(axis: .vertical)
        vStack.backgroundColor = .appWhite
        cells.forEach {
            vStack.addArrangedSubview(getSeparatorView())
            vStack.addArrangedSubview($0)
        }

        [titleLabel, ViewsFactory.wrapView(vStack)].forEach { stackView.addArrangedSubview($0) }
    }

    func showError() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }

        let label = ViewsFactory.defaultLabel(alignment: .center)
        label.text = ^String.ProductScanResult.somethingWentWrong
        tryAgainButton.setTitle(^String.ProductScanResult.tryAgain, for: .normal)
        let hStack = ViewsFactory.defaultStackView(axis: .vertical, spacing: 10)
        hStack.backgroundColor = .appWhite
        [label, tryAgainButton].forEach { hStack.addArrangedSubview($0) }

        [titleLabel, ViewsFactory.wrapView(hStack.wrap())].forEach { stackView.addArrangedSubview($0) }
    }

    func showEmptyState() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let label = ViewsFactory.defaultLabel(alignment: .center)
        label.text = ^String.Last.nothingFoundLabelTitle
        label.height(50)

        [titleLabel, ViewsFactory.wrapView(label)].forEach { stackView.addArrangedSubview($0) }
    }

    private func getSeparatorView(axis: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        let separator = ViewsFactory.separatorLine(axis: axis)
        if axis == .horizontal {
            let separatorView = UIView()
            separatorView.addSubview(separator)
            separator.horizontalToSuperview(insets: .left(16))
            return separatorView
        }
        return separator
    }

}

class AbstractFoodInfoCardPresenter: AbstractCardPresenter {

    let foodCardView = FoodInfoCardView()

    override func cardView() -> UIView {
        return foodCardView
    }

    func showLoadingState() {
        foodCardView.showLoadingState()
    }

    func showData(food: EdamamFood?, nutrientsInfo: (measure: EdamamMeasure, nutrients: EdamamNutrients)?) {
        // will be overriden by subclass
    }

    func showError() {
        foodCardView.showError()
    }

}

class CommonFoodInfoCardPresenter: AbstractFoodInfoCardPresenter {

    override init(controller: UIViewController) {
        super.init(controller: controller)
        foodCardView.titleLabel.text = ^String.Product.foodInformation
    }

    override func showData(food: EdamamFood?, nutrientsInfo: (measure: EdamamMeasure, nutrients: EdamamNutrients)?) {
        guard let food = food else {
            foodCardView.showError()
            return
        }
        let data = [
            (^String.Product.scannedResult, food.label),
            (^String.Product.dishType, food.categoryLabel),
            (^String.Product.category, food.category)
        ]
        foodCardView.showData(data)
    }

}

private enum NutrientsConstants {
    static let baseNutrientKeys = [
        "ENERC_KCAL",
        "PROCNT",
        "FAT",
        "CHOCDF",
        "FIBTG"
    ]
}

class NutrientsFoodInfoCardPresenter: AbstractFoodInfoCardPresenter {

    override init(controller: UIViewController) {
        super.init(controller: controller)
        foodCardView.titleLabel.text = ^String.Product.nutrientsTitle
    }

    override func showData(food: EdamamFood?, nutrientsInfo: (measure: EdamamMeasure, nutrients: EdamamNutrients)?) {
        guard let nutrients = nutrientsInfo?.nutrients,
              let measure = nutrientsInfo?.measure else {
            foodCardView.showEmptyState()
            return
        }
        let baseNutrients = EdamamNutrients.baseNutrientKeys.compactMap { nutrients.totalNutrients[$0] }
        let data = baseNutrients.map { ($0.label, String(format: "%.2f %@", $0.quantity, $0.unit)) }
        foodCardView.showData(data)
        foodCardView.titleLabel.text = ^String.Product.nutrientsTitle + " (\(measure.label))"
    }

}

class MicronutrientsFoodInfoCardPresenter: AbstractFoodInfoCardPresenter {

    override init(controller: UIViewController) {
        super.init(controller: controller)
        foodCardView.titleLabel.text = ^String.Product.micronutrientsTitle
    }

    override func showData(food: EdamamFood?, nutrientsInfo: (measure: EdamamMeasure, nutrients: EdamamNutrients)?) {
        guard let nutrients = nutrientsInfo?.nutrients,
              let measure = nutrientsInfo?.measure else {
            foodCardView.showEmptyState()
            return
        }
        let baseNutrientKeys = EdamamNutrients.baseNutrientKeys
        let restNutrients = nutrients.totalNutrients.filter { !baseNutrientKeys.contains($0.key) }
        let data = restNutrients.map { ($0.value.label, String(format: "%.2f %@", $0.value.quantity, $0.value.unit)) }
        foodCardView.showData(data)
        foodCardView.titleLabel.text = ^String.Product.micronutrientsTitle + " (\(measure.label))"
    }

}
