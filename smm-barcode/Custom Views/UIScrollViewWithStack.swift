//
//  UIScrollViewWithStack.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

class UIScrollViewWithStack: UIScrollView {

    let stack = UIStackView()

    required init(axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 0) {
        super.init(frame: .zero)
        stack.axis = axis
        stack.spacing = spacing
        setupLayout()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMargins(_ margins: UIEdgeInsets) {
        stack.layoutMargins = margins
        stack.isLayoutMarginsRelativeArrangement = true
    }

    // MARK: - Private helpers

    private func setupLayout() {
        addSubview(stack)
        stack.edgesToSuperview()
        if stack.axis == .vertical {
            stack.widthToSuperview()
        } else {
            stack.heightToSuperview()
        }
    }

}
