//
//  HistoryListPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 08.04.2023.
//

import Foundation
import UIKit

class HistoryListPresenter: NSObject, HistoryLayoutPresenterProtocol {

    weak var delegate: HistoryLayoutPresenterDelegate?
    private let tableView = ViewsFactory.defaultTableView(style: .insetGrouped)
    private(set) var sections: [(date: Date, items: [ScanModel])] = []

    var isEditing: Bool {
        get {
            return tableView.isEditing
        } set {
            tableView.setEditing(newValue, animated: true)
        }
    }

    override init() {
        super.init()
        setupTableView()
    }

    func getView() -> UIView {
        return tableView
    }

    func showItems(_ items: [ScanModel]) {
        var groupedItems: [Date: [ScanModel]] = [:]
        items.forEach { item in
            let date = item.date.dateExceptTime
            let items = (groupedItems[date] ?? []) + [item]
            groupedItems[date] = items
        }
        sections = groupedItems.map { ($0, $1) }.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        tableView.reloadData()
    }

    // MARK: - Helpers

    private func setupTableView() {
        tableView.backgroundColor = .appLightGray3
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.description())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
    }

}

extension HistoryListPresenter: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = MomentJS.calendar(sections[section].date) ?? ""
        return ViewsFactory.defaultHeaderView(text: title.uppercased())
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.description()) else {
            fatalError("Failed cell dequeue")
        }
        let model = sections[indexPath.section].items[indexPath.row]
        (cell as? HistoryTableViewCell)?.setData(item: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let model = sections[indexPath.section].items[indexPath.row]
        delegate?.didSelectCell(with: model)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section].items[indexPath.row]
        delegate?.didDeselectCell(with: model)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = sections[indexPath.section].items[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: ^String.History.delete) { [weak self] _, _, _ in
            self?.delegate?.removeItem(item)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = sections[indexPath.section].items[indexPath.row]
        return delegate?.contextMenuConfigurator(item: item)
    }

}
