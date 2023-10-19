//
//  SettingsViewController.swift
//  smm-barcode
//
//  Created by Daniil on 08.03.2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Properties

    private let tableView = ViewsFactory.defaultTableView(style: .insetGrouped)
    private lazy var helper = SettingsSectionsHelper(controller: self)
    private var sections: [SettingsSection] = []
    let subscriptionsManager = AppSubscriptionManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitles()
        setupViews()
        setupLayout()
        setupHandlers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSections()
    }

    // MARK: - Helpers

    private func setTitles() {
        navigationItem.title = ^String.Root.settingsTitle
    }

    private func setupViews() {
        view.backgroundColor = .appLightGray3
        tableView.layoutMargins = .horizontal(16)
        tableView.separatorInset = .left(57)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.edgesToSuperview()
    }

    private func setupHandlers() {
        subscriptionsManager.addDelegate(self)
        setDismissLeftBarButtonItem()
    }

    private func updateSections() {
        sections = helper.buildSections()
        tableView.reloadData()
    }

    private func pushController(_ controller: UIViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Handlers

    func showSubscriptions() {
        pushController(SubscriptionsViewController())
    }

    func contactSupport() {
        openLinkURL(Constants.supportURL)
    }

    func shareApp(sourceView: UIView) {
        let activityVc = UIActivityViewController(activityItems: [ShareActivityItemSource()], applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = sourceView
        present(activityVc, animated: true)
        print("shareApp handler")
    }

    func showPrivacyPolicy() {
        openLinkURL(Constants.privacyURL)
    }

    func showTermsOfUsage() {
        openLinkURL(Constants.tosURL)
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].items[indexPath.row].cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ViewsFactory.defaultHeaderView(text: sections[section].title)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].description == nil ? 0 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let description = sections[section].description else {
            return nil
        }
        let label = ViewsFactory.defaultLabel(font: .regular(13), textColor: .appSystemGray, lines: 0, adjustFont: true)
        label.text = description
        let footerView = UIView()
        footerView.addSubview(label)
        label.edgesToSuperview(insets: .vertical(10))
        return footerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        if !item.isDisabled {
            item.handler?(item.cell)
        }
    }

}

// MARK: - AppSubscriptionManagerDelegate

extension SettingsViewController: AppSubscriptionManagerDelegate {

    func subscriptionStateUpdated(_ active: Bool) {
        updateSections()
    }

}
