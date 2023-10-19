//
//  ButtonView.swift
//  smm-barcode
//
//  Created by Daniil on 07.03.2023.
//

import TinyConstraints
import UIKit

class ButtonView: UIView {

    // MARK: - Properties

    private let stackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 4, alignment: .center)
    fileprivate let button = ViewsFactory.defaultButton(color: .appGray, radius: 9)
    private let label = ViewsFactory.defaultLabel(font: .regular(13), textColor: .appWhite, alignment: .center)

    // MARK: - Life Cycle

    required init(image: UIImage?, title: String, target: Any, selector: Selector) {
        super.init(frame: .zero)
        button.setImage(image, for: .normal)
        button.tintColor = .appWhite
        button.addTarget(target, action: selector, for: .touchDown)
        label.text = title
        setLayout()
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setLayout() {
        addSubview(stackView)
        let buttonSize = CGSize(width: 44, height: 44)
        button.size(buttonSize)
        stackView.edgesToSuperview()
        [button, label].forEach {
            stackView.addArrangedSubview($0)
        }
    }
}

class LightButton: ButtonView {
    private var lightStateOn = false {
        didSet {
            guard let image = lightStateOn ? AppImage.rootLightningFill.uiImage : AppImage.rootLightning.uiImage else {
                return
            }
            button.setImage(image, for: .normal)
        }
    }

    convenience init(target: Any, selector: Selector) {
        self.init(image: AppImage.rootLightning.uiImage, title: ^String.Root.lightTitle, target: target, selector: selector)
    }

    func changeLightState() {
        lightStateOn.toggle()
    }

    func turnOff() {
        lightStateOn = false
    }

}
