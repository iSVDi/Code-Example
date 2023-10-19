//
//  SettingsSectionsHelper.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 04.06.2022.
//

import UIKit

struct SettingsSection {

    let title: String
    let items: [SettingsItem]
    let description: String?

    init(
        title: String,
        items: [SettingsItem],
        description: String? = nil
    ) {
        self.title = title
        self.items = items
        self.description = description
    }

}

struct SettingsItem {

    let cell = SettingsTableViewCell()
    let handler: ((SettingsTableViewCell) -> Void)?
    let isDisabled: Bool

    init(
        image: AppImage,
        title: String,
        description: String? = nil,
        view: UIView? = nil,
        disabled: Bool = false,
        handler: ((SettingsTableViewCell) -> Void)? = nil
    ) {
        self.handler = handler
        isDisabled = disabled
        cell.imageView?.image = image.uiImage
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = description
        cell.selectionStyle = handler == nil || isDisabled ? .none : .default
        let view = view ?? chevronImageView()
        view.sizeToFit()
        cell.accessoryView = view
        cell.setDisabled(disabled)
    }

    private func chevronImageView() -> UIImageView {
        let image = AppImage.commonChevronRight.uiImageWith(tint: .appSystemGray)
        return ViewsFactory.defaultImageView(image: image)
    }

}

class SettingsSectionsHelper {

    private weak var controller: SettingsViewController!

    private var hasSubscription: Bool {
        return controller.subscriptionsManager.hasSubscription
    }

    private let limitsManager = AppLimitsManager.shared

    required init(controller: SettingsViewController) {
        self.controller = controller
    }

    func buildSections() -> [SettingsSection] {
        let sections = [buildAccountSection(), buildGeneralSection()]
        return sections
    }

    // MARK: - Private Helpers

    private func buildAccountSection() -> SettingsSection {
        let licenseLabel = ViewsFactory.defaultLabel(font: .regular(17))
        licenseLabel.text = ^(hasSubscription ? String.Settings.premiumTitle : .freeTitle)
        licenseLabel.textColor = hasSubscription ? .appSystemBlue : .appSystemGray
        let licenseItem = SettingsItem(image: .settingsPersonSquare, title: ^String.Settings.licenseTitle, view: licenseLabel)

        let limitFont = UIFont.regular(17)
        let limitTextColor = UIColor.appSystemGray
        let barcodeLimitLabel = ViewsFactory.defaultLabel(font: limitFont, textColor: limitTextColor)
        let productLimitLabel = ViewsFactory.defaultLabel(font: limitFont, textColor: limitTextColor)
        let documentLimitLabel = ViewsFactory.defaultLabel(font: limitFont, textColor: limitTextColor)

        if hasSubscription {
            barcodeLimitLabel.attributedText = getInfinityString(font: limitFont)
            [barcodeLimitLabel, productLimitLabel, documentLimitLabel].forEach {
                $0.attributedText = getInfinityString(font: limitFont)
            }
        } else {
            barcodeLimitLabel.text = String.Settings.numberOfNumberString.format(limitsManager.barcodeScans, limitsManager.barcodeLimit)
            productLimitLabel.text = String.Settings.numberOfNumberString.format(limitsManager.productScans, limitsManager.productLimit)
            documentLimitLabel.text = String.Settings.numberOfNumberString.format(limitsManager.documentScans, limitsManager.documentLimit)
        }

        let barcodeLimitItem = SettingsItem(image: .settingsClockArrowCirclePath, title: ^String.Settings.barcodeLimitTitle, view: barcodeLimitLabel)
        let productLimitItem = SettingsItem(image: .settingsClockArrowCirclePath, title: ^String.Settings.productLimitTitle, view: productLimitLabel)
        let documentLimitItem = SettingsItem(image: .settingsClockArrowCirclePath, title: ^String.Settings.documentLimitTitle, view: documentLimitLabel)

        let items = [licenseItem, barcodeLimitItem, productLimitItem, documentLimitItem]
        return SettingsSection(title: ^String.Settings.accountUppercasedTitle, items: items)
    }

    private func buildGeneralSection() -> SettingsSection {
        let subscriptionsItem = SettingsItem(image: .settingsGoforwardSquare, title: ^String.Settings.subscriptionsTitle) { [weak self] _ in
            self?.controller.showSubscriptions()
        }

        let contactSupportItem = SettingsItem(image: .settingsMessageSquare, title: ^String.Settings.contactSupportTitle) { [weak self] _ in
            self?.controller.contactSupport()
        }
        let shareOurAppItem = SettingsItem(image: .settingsArrowshapeRightSquare, title: ^String.Settings.shareOurAppTitle) { [weak self] cell in
            self?.controller.shareApp(sourceView: cell)
        }
        let privacyPolicyItem = SettingsItem(image: .settingsDocSquare, title: ^String.Trial.privacyPolicy) { [weak self] _ in
            self?.controller.showPrivacyPolicy()
        }
        let termsOfUsageItem = SettingsItem(image: .settingsDocSquare, title: ^String.Trial.termsOfUsage) { [weak self] _ in
            self?.controller.showTermsOfUsage()
        }
        let items = [subscriptionsItem, contactSupportItem, shareOurAppItem, privacyPolicyItem, termsOfUsageItem]
        return SettingsSection(title: ^String.Settings.generalUppercasedTitle, items: items)
    }

    private func getInfinityString(font: UIFont) -> NSAttributedString? {
        guard let image = AppImage.settingsInfinity.uiImageWith(font: font, tint: .appSystemBlue) else {
            return nil
        }
        let infinityAttachment = NSTextAttachment(image: image)
        return NSAttributedString(attachment: infinityAttachment)
    }

}
