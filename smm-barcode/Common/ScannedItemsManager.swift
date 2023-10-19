//
//  ScannedItemsManager.swift
//  smm-barcode
//
//  Created by Daniil on 20.03.2023.
//

import AVFoundation
import Foundation
import PDFKit
import VisionKit

struct ScannedSections {
    var title: String {
        if let date = stringDate.getDate(Constants.noTimeDateFormat),
           let formattedTitle = MomentJS.calendar(date) {
            return formattedTitle.uppercased()
        }
        return stringDate
    }

    let stringDate: String
    var cells: [ScanModel]

    init(title: String, cells: [ScanModel]) {
        stringDate = title
        self.cells = cells
    }
}

struct ScannedItem {
    let cell = HistoryTableViewCell()

    init(model: ScanModel) {
        cell.setData(item: model)
    }
}

class ScannedItemsManager {

    static let itemsUpdateNotification = Notification.Name("ScannedItemsUpdateNotification")
    static let shared = ScannedItemsManager()
    private let scannedCodesDatabase = ScannedCodesDatabase()
    private let thumbnailHelper = ThumbnailHelper.shared
    private(set) var items: [ScanModel] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: ScannedItemsManager.itemsUpdateNotification, object: nil)
            }
        }
    }

    init() {
        fetchDatabase { _ in }
    }

    // MARK: - Methods

    func fetchDatabase(completion: @escaping (Error?) -> Void) {
        scannedCodesDatabase.getAllItems { [self] result in
            switch result {
            case let .success(items):
                self.items = items
                completion(nil)
            case let .failure(error):
                print(error.localizedDescription)
                completion(error)
            }
        }
    }

    func addItem(_ object: ScanModel, completion: @escaping (Result<ScanModel, Error>) -> Void) {
        scannedCodesDatabase.addItemData(object) { result in
            if case let .success(item) = result {
                self.items.append(item)
            }
            completion(result)
        }
    }

    func removeItem(_ item: ScanModel, completion: @escaping (Error?) -> Void) {
        scannedCodesDatabase.removeItem(item) { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.items.removeAll { $0.id == item.id }
            completion(nil)
        }
    }

    // INFO: There are didSet(for items) that call Notification Center.post.
    // It's reason why we cannot reuse func remove Item and need new func for removing bunch of items and updating items once
    func removeItemsBunch(_ items: [ScanModel], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        var oldItems = self.items
        items.forEach { item in
            dispatchGroup.enter()
            scannedCodesDatabase.removeItem(item) { error in
                dispatchGroup.leave()
                guard error == nil else {
                    return
                }
                oldItems = oldItems.filter { $0.id != item.id }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.items = oldItems
            completion()
        }
    }

    func removePDF(_ item: ScanModel, completion: @escaping (Error?) -> Void) {
        removeItem(item) { error in
            if error == nil {
                let url = URL.pdfDocument(name: item.data)
                try? FileManager.default.removeItem(at: url)
            }
            completion(error)
        }
    }

    func writePDF(scan: VNDocumentCameraScan, completion: @escaping (ScanModel?) -> Void) {
        if !FileManager.default.fileExists(atPath: URL.pdfDocumentsDirectory.path) {
            try? FileManager.default.createDirectory(at: URL.pdfDocumentsDirectory, withIntermediateDirectories: true)
        }

        let date = Date()
        let documentName = date.fileName(with: "pdf")
        let url = URL.pdfDocument(name: documentName)
        let document = ScanModel(id: 0, type: .pdf, date: date, dataFormat: "document", data: documentName)

        let finalBlock: () -> Void = { [weak self] in
            guard let welf = self else {
                completion(nil)
                return
            }
            welf.addItem(document) { result in
                if case let .success(addedItem) = result {
                    self?.thumbnailHelper.thumbnail(
                        of: url,
                        size: HistoryCellConstants.imageViewSize
                    ) { _, _ in }
                    completion(addedItem)
                } else {
                    completion(nil)
                }
            }
        }
        // performing a resource-intensive operation not on the main thread
        DispatchQueue.global().async {
            let pdfDocument = PDFDocument()
            (0 ..< scan.pageCount).forEach {
                let image = scan.imageOfPage(at: $0)
                let pdfPage = PDFPage(image: image) ?? PDFPage()
                pdfDocument.insert(pdfPage, at: $0)
            }

            let result = pdfDocument.write(to: url)
            DispatchQueue.main.async {
                if result {
                    finalBlock()
                } else {
                    completion(nil)
                }
            }
        }
    }

}
