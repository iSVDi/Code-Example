//
//  SettingsTableViewCell.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 04.06.2022.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func setDisabled(_ disabled: Bool) {
        let alpha: CGFloat = disabled ? 0.3 : 1
        [imageView, textLabel, detailTextLabel].forEach {
            $0?.alpha = alpha
        }
        if let button = accessoryView as? UIButton {
            button.isEnabled = !disabled
            [button.imageView, button.titleLabel].forEach {
                $0?.alpha = alpha
            }
        }
    }

    // MARK: - Helpers

    private func commonInit() {
        imageView?.layer.cornerRadius = 6
        imageView?.clipsToBounds = true
        textLabel?.font = .regular(17)
        textLabel?.textColor = .appBlack
        detailTextLabel?.font = .regular(17)
        detailTextLabel?.textColor = .appSystemGray
    }

}
