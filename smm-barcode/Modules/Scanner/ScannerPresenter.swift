//
//  ScannerPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 12.04.2023.
//

import AVFoundation
import UIKit
import VisionKit

class ScannerPresenter: NSObject {

    private weak var controller: ScannerViewController?
    private var lastTimerTask = DispatchWorkItem {}
    init(controller: ScannerViewController) {
        super.init()
        self.controller = controller
        ScannedItemsManager.shared.fetchDatabase(completion: { _ in })
    }

    func openHistory() {
        let historyViewController = HistoryViewController()
        controller?.presentFullScreenController(controller: historyViewController)
    }

    func openProducts() {
        let productViewController = ProductScannerViewController(scanProductHandler: { [weak self] in
            self?.controller?.scannerMode = .product
        })
        controller?.presentFullScreenController(controller: productViewController)
    }

    func openDocumentsScanner() {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = self
        controller?.present(documentViewController, animated: true)
    }

    func handleScanResult(_ barcodes: [AVMetadataMachineReadableCodeObject]) {
        guard let barcode = barcodes.first, let mode = controller?.scannerMode, let type = scannedItemType(barcode: barcode, mode: mode) else {
            DispatchQueue.main.async { [weak self] in
                guard let welf = self else {
                    return
                }
                welf.lastTimerTask.cancel()
                welf.controller?.session.startRunning()
                welf.changeToastVisibility(true)
                let task = DispatchWorkItem {
                    welf.changeToastVisibility(false)
                }
                self?.lastTimerTask = task
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: welf.lastTimerTask)
            }
            return
        }
        // id = 0 - is temp value
        let model = ScanModel(
            id: 0,
            type: type,
            date: Date(),
            dataFormat: barcode.type.rawValue,
            data: barcode.stringValue ?? ""
        )
        ScannedItemsManager.shared.addItem(model) { [weak self] result in
            switch result {
            case let .success(addedItem):
                /*
                 INFO: -  without DispatchQueue.main.async there will be error
                 "Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread."
                 */
                DispatchQueue.main.async {
                    self?.controller?.showResultViewController(addedItem)
                }
            case let .failure(error):
                self?.controller?.showErrorAlert(error.localizedDescription)
                self?.controller?.session.startRunning()
            }
        }
    }

    // MARK: - Handlers

    private func changeToastVisibility(_ placeBarcodeIsHidden: Bool) {
        controller?.placeBarcodeLabel.isHidden = placeBarcodeIsHidden
        controller?.noRecognizedBarcodeLabel.isHidden = !placeBarcodeIsHidden
    }

    // MARK: - Helpers

    private func openDocumentScanResult(_ model: ScanModel) {
        let viewController = DocumentScanResultViewController(document: model)
        controller?.presentFullScreenController(controller: viewController)
    }

    private func scannedItemType(barcode: AVMetadataMachineReadableCodeObject, mode: ScannerViewController.Mode) -> ScanModel.ScanType? {
        if mode == .product {
            return barcode.type == .qr ? nil : .product
        }
        return barcode.type == .qr ? .qr : .barcode
    }

}

extension ScannerPresenter: VNDocumentCameraViewControllerDelegate {

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) { [weak self] in
            self?.processScanResult(scan)
        }
    }

    private func processScanResult(_ scan: VNDocumentCameraScan) {
        controller?.showHUD()
        ScannedItemsManager.shared.writePDF(scan: scan) { [weak self] model in
            self?.controller?.hideHUD()
            if let model = model {
                self?.openDocumentScanResult(model)
            } else {
                self?.controller?.showErrorAlert(^String.ErrorsDescription.failedDocumentScanSaving)
            }
        }
    }

}
