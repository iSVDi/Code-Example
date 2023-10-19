//
//  SubscriptionPlansView.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import UIKit

class SubscriptionPlansView: UIView {

    private let isAlternative: Bool
    private let stackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 9)
    private var plansView: [SubscriptionPlanView] {
        return stackView.subviews as? [SubscriptionPlanView] ?? []
    }

    private(set) var selectedIndex = -1 {
        didSet {
            selectedPlanViewAt?(selectedIndex)
        }
    }

    var selectedPlanViewAt: ((Int) -> Void)?

    required init(isAlternative: Bool = false) {
        self.isAlternative = isAlternative
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSubscriptionPlans(_ plans: [AppSubscriptionInfo]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for plan in plans {
            let planView = SubscriptionPlanView(isAlternative: isAlternative)
            if isAlternative && plan.type == .yearly {
                planView.setSelectedState(true)
            }
            planView.setupWithInfo(plan)
            planView.viewButton.addTarget(self, action: #selector(subscriptionViewPressed), for: .touchUpInside)
            stackView.addArrangedSubview(planView)
        }
        guard !isAlternative, let planView = plansView.first else {
            return
        }
        subscriptionViewPressed(planView.viewButton)
    }

    // MARK: - Handlers

    @objc private func subscriptionViewPressed(_ sender: UIButton) {
        guard let selectedView = sender.superview as? SubscriptionPlanView else {
            return
        }
        plansView.forEach { $0.setSelectedState(false) }
        selectedView.setSelectedState(true)
        selectedIndex = plansView.firstIndex(of: selectedView) ?? -1
    }

}
